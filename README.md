# PrefixedAPIKey

`PrefixedAPIKey` is a quick Elixir port of Seam's Javascript 
[Prefixed API Key](https://github.com/seamapi/prefixed-api-key) library. 
It creates and verifies simple, random authentication tokens that have two useful prefix parts.

This version is a little different (it has a smaller set of functions and uses a slightly bigger character set) 
but appears to be compatible with the original.

## Installation

The package can be installed by adding `prefixed_api_key` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:prefixed_api_key, "~> 0.1.0"}
  ]
end
```

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

## Examples
```elixir

    {:ok, key} = PrefixedApiKey.generate("myapp")
    # => 
    #    {:ok,
    #      %PrefixedApiKey{
    #        api_key: "myapp_ZLXZ3PYn_E34CUQSRtlmf0CMLsKFjMOf7",
    #        hash: "d5264a8fef50459c35306c35396c446cf88f8755c06ff70c341eb3fbd606ca44",
    #        long_token: "E34CUQSRtlmf0CMLsKFjMOf7",
    #        prefix: "myapp",
    #        short_token: "ZLXZ3PYn"
    #      }}

    key.api_key
    # => "myapp_ZLXZ3PYn_E34CUQSRtlmf0CMLsKFjMOf7"
    
    {:ok, key} = PrefixedApiKey.parse("myapp_ZLXZ3PYn_E34CUQSRtlmf0CMLsKFjMOf7")
    # => 
    #    {:ok,
    #      %PrefixedApiKey{
    #        api_key: "myapp_ZLXZ3PYn_E34CUQSRtlmf0CMLsKFjMOf7",
    #        hash: "d5264a8fef50459c35306c35396c446cf88f8755c06ff70c341eb3fbd606ca44",
    #        long_token: "E34CUQSRtlmf0CMLsKFjMOf7",
    #        prefix: "myapp",
    #        short_token: "ZLXZ3PYn"
    #      }}

    PrefixedApiKey.verify?("myapp_ZLXZ3PYn_E34CUQSRtlmf0CMLsKFjMOf7", "d5264a8fef50459c35306c35396c446cf88f8755c06ff70c341eb3fbd606ca44")
    # => true

```


## API Documentation

Full API documentation can be found at
[https://hexdocs.pm/prefixed_api_key](https://hexdocs.pm/prefixed_api_key).

## Contributing

You can request new features by creating an [issue](https://github.com/Digital-Identity-Labs/prefixed_api_key/issues),
or submit a [pull request](https://github.com/Digital-Identity-Labs/prefixed_api_key/pulls) with your contribution.

## References

* The original [Prefixed API Key](https://github.com/seamapi/prefixed-api-key)
* [Discussion on the original library at Hacker News](https://news.ycombinator.com/item?id=31333933#31336542)

## Copyright and License

Copyright (c) 2022 Digital Identity Ltd, UK

PrefixedAPIKey is MIT licensed.
