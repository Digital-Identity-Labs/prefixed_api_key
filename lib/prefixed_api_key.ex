defmodule PrefixedApiKey do

  alias __MODULE__
  alias PrefixedApiKey.LongToken
  alias PrefixedApiKey.ShortToken

  @api_key_structure  ~r/^(?<prefix>[a-zA-Z0-9]+)_(?<short>[a-zA-Z0-9]{8})_(?<long>[a-zA-Z0-9]{24})$/
  @prefix_format ~r/[a-zA-Z0-9]{1,32}/

  @enforce_keys [:prefix, :short_token, :long_token, :hash, :api_key]

  defstruct [
    :prefix,
    :short_token,
    :long_token,
    :hash,
    :api_key
  ]

  def generate(raw_prefix) do
    with {:ok, prefix} <- normalise_prefix(raw_prefix) do
      short = ShortToken.generate()
      long = LongToken.generate()
      assemble_prefixed_key(prefix, short, long)
    else
      {:error, message} -> {:error, message}
    end
  end

  def parse(api_key = %PrefixedApiKey{}) do

    Apex.ap api_key

    {:ok, api_key}
  end

  def parse(api_key) do
    case Regex.named_captures(@api_key_structure, api_key) do
      %{"long" => long, "prefix" => prefix, "short" => short} ->
        assemble_prefixed_key(prefix, short, long)
      nil -> {:error, "Cannot extract token information from the API key"}
    end
  end

  def valid?(api_key, hash, short) do
    with {:ok, key} <- parse(api_key)
      do
      key.short_token == short && key.hash == hash
    else
      _ -> false
    end
  end

  def valid?(api_key, hash) do
    with {:ok, key} <- parse(api_key)
      do
      key.hash == hash
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

end


#   shortToken: 'BRTRKFsL',
#longToken: '51FwqftsmMDHHbJAMEXXHCgG',
#longTokenHash: 'd70d981d87b449c107327c2a2afbf00d4b58070d6ba571aac35d7ea3e7c79f37',
#               token: 'mycompany_BRTRKFsL_51FwqftsmMDHHbJAMEXXHCgG'