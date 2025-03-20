defmodule PrefixedApiKey do
  @moduledoc """
  `PrefixedAPIKey` is a quick Elixir port of Seam's Javascript
  [Prefixed API Key](https://github.com/seamapi/prefixed-api-key) library.
  It creates and verifies simple, random authentication tokens that have two useful prefix parts.

  This version is a little different (it has a smaller set of functions and uses a slightly bigger character set)
  but appears to be compatible with the original.

  ## Overview

  Example key:
  > `mycompany_BRTRKFsL_51FwqftsmMDHHbJAMEXXHCgG`

  Seam-style API Keys have these benefits:

  - Double clicking the api key usually selects the entire api key
  - The alphabet is standard across languages (the original uses Base58, this uses a slightly larger alphanumeric ASCII set)
  - They are shorter than hex and base32 api keys
  - They have prefixes [allowing secret scanning by github](https://docs.github.com/en/code-security/secret-scanning/about-secret-scanning)
  - They have a hashed component so the server doesn't need to store the api key (reducing attack surface)
  - They have unhashed short tokens which can be mutually used by the server and key bearer/customer to identify the api key
  - They default to roughly the same number of entropy bits as UUIDv4

  ## The Format

  Prefixed API Keys look like this:

  ```
  mycompany_BRTRKFsL_51FwqftsmMDHHbJAMEXXHCgG
  ```

  Components:

  ```
  mycompany ..._...  BRTRKFsL ..._...  51FwqftsmMDHHbJAMEXXHCgG
  ^                  ^                 ^
  Prefix             Short Token       Long Token
  ```

  - The *Prefix* is used to identify the company or service creating the API Key.
  This is very helpful in secret scanning.
  - The *Short Token* is stored by both the server and the key bearer/customer, it
  can be used to identify an API key in logs or displayed on a customer's
  dashboard. A token can be deny-listed by its short token.
  - The *Long Token* is how we authenticate this key. The long token is never stored
  on the server, but a hash of it is stored on the server. When we receive an
  incoming request, we search our database for `short_token` and `hash`.

  ## Example

      iex> {:ok, key} = PrefixedApiKey.generate("example")
      iex> api_key = key.api_key
      iex> {:ok, _key} = PrefixedApiKey.parse(api_key)

      iex> PrefixedApiKey.verify?("myapp_ZLXZ3PYn_E34CUQSRtlmf0CMLsKFjMOf7", "d5264a8fef50459c35306c35396c446cf88f8755c06ff70c341eb3fbd606ca44")
      true

  """

  alias __MODULE__
  alias PrefixedApiKey.LongToken
  alias PrefixedApiKey.ShortToken

  import Bitwise

  @api_key_structure  ~r/^(?<prefix>[a-zA-Z0-9]+)_(?<short>[a-zA-Z0-9]{8})_(?<long>[a-zA-Z0-9]{24})$/
  @prefix_format ~r/^[a-zA-Z0-9]{1,32}$/

  @enforce_keys [:prefix, :short_token, :long_token, :hash, :api_key]

  @type t :: %PrefixedApiKey{
               prefix: binary(),
               short_token: binary(),
               long_token: binary(),
               hash: binary(),
               api_key: binary(),
             }

  defstruct [
    :prefix,
    :short_token,
    :long_token,
    :hash,
    :api_key
  ]

  @doc """
  Generates a new API key, using the specified prefix

  Use the prefix to identify keys for *your* application.

  ## Example

      iex> PrefixedApiKey.generate("doormouse")


  """
  @spec generate(prefix :: binary | PrefixedApiKey.t()) :: {:ok, PrefixedApiKey.t()} | {:error, binary}
  def generate(prefix) do
    with {:ok, prefix} <- normalise_prefix(prefix) do
      short = ShortToken.generate()
      long = LongToken.generate()
      assemble_prefixed_key(prefix, short, long)
    else
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Parses a prefixed API Key string into its component parts, and produces a hash of the long token.

  (You can also parse an already-parsed key)

  ## Example

     iex> PrefixedApiKey.parse("mycompany_BRTRKFsL_51FwqftsmMDHHbJAMEXXHCgG")
     {:ok, %PrefixedApiKey{
               prefix: "mycompany",
               short_token: "BRTRKFsL",
               long_token: "51FwqftsmMDHHbJAMEXXHCgG",
               api_key: "mycompany_BRTRKFsL_51FwqftsmMDHHbJAMEXXHCgG",
               hash: "d70d981d87b449c107327c2a2afbf00d4b58070d6ba571aac35d7ea3e7c79f37"
             }}

  """
  @spec parse(api_key :: binary | PrefixedApiKey.t()) :: {:ok, PrefixedApiKey.t()} | {:error, binary}
  def parse(api_key = %PrefixedApiKey{}) do
    {:ok, api_key}
  end

  def parse(api_key) do
    case Regex.named_captures(@api_key_structure, api_key) do
      %{"long" => long, "prefix" => prefix, "short" => short} ->
        assemble_prefixed_key(prefix, short, long)
      nil -> {:error, "Cannot extract token information from the API key"}
    end
  end

  @doc """
  Compares an Prefixed API Key string (or struct) to a hash you have previously stored, for verification of the key.

  ## Example

      iex> PrefixedApiKey.verify?(
      ...>        "mycompany_BRTRKFsL_51FwqftsmMDHHbJAMEXXHCgG",
      ...>        "d70d981d87b449c107327c2a2afbf00d4b58070d6ba571aac35d7ea3e7c79f37")
      true

  """
  @spec verify?(api_key :: binary | PrefixedApiKey.t(), hash :: binary, short :: binary) :: true | false
  def verify?(api_key, hash, short) do
    with {:ok, key} <- parse(api_key)
      do
      key.short_token == short && secure_compare(key.hash, hash)
    else
      _ -> false
    end
  end

  @doc """
  Compares an Prefixed API Key string (or struct) to a hash and short token that you have previously stored, for verification of the key.

  ## Example

      iex> PrefixedApiKey.verify?(
      ...>   "mycompany_BRTRKFsL_51FwqftsmMDHHbJAMEXXHCgG",
      ...>   "d70d981d87b449c107327c2a2afbf00d4b58070d6ba571aac35d7ea3e7c79f37",
      ...>   "BRTRKFsL")
      true

  """
  @spec verify?(api_key :: binary | PrefixedApiKey.t(), hash :: binary) :: true | false
  def verify?(api_key, hash) do
    with {:ok, key} <- parse(api_key) do
      secure_compare(key.hash, hash)
    else
      _ -> false
    end
  end

  defp api_key_string(prefix, short, long) do
    "#{prefix}_#{short}_#{long}"
  end

  defp hash(long) do
    :crypto.hash(:sha256, long)
    |> Base.encode16
    |> String.downcase
  end

  defp normalise_prefix(prefix) do
    prefix = String.trim(prefix)
    if String.match?(prefix, @prefix_format) do
      {:ok, prefix}
    else
      {:error, "Prefix is invalid!"}
    end
  end

  defp assemble_prefixed_key(prefix, short, long) do
    hashed = hash(long)
    pak_struct = %PrefixedApiKey{
      prefix: prefix,
      short_token: short,
      long_token: long,
      hash: hashed,
      api_key: api_key_string(prefix, short, long)
    }
    {:ok, pak_struct}
  end



  ## http://codahale.com/a-lesson-in-timing-attacks/
  @spec secure_compare(binary(), binary()) :: boolean()
  defp secure_compare(left, right) when is_binary(left) and is_binary(right) do
    byte_size(left) == byte_size(right) and secure_compare(left, right, 0)
  end

  defp secure_compare(<<x, left::binary>>, <<y, right::binary>>, acc) do
    xorred = bxor(x, y)
    secure_compare(left, right, acc ||| xorred)
  end

  defp secure_compare(<<>>, <<>>, acc) do
    acc === 0
  end

end
