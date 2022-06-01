defmodule PrefixedApiKeyTest do
  use ExUnit.Case
  doctest PrefixedApiKey

  describe "generate/1" do

    test "returns a PrefixedApiKey structure in result tuple" do
      assert {:ok, %PrefixedApiKey{}} = PrefixedApiKey.generate("myapp")
    end

    test "returns an error when passed an invalid prefix" do
      assert {:error, "Prefix is invalid!"} = PrefixedApiKey.generate("my_app.com")
    end

    test "returns a generated PrefixedAPIKey containing the normalised prefix" do
      assert {:ok, %PrefixedApiKey{prefix: "acme"}} = PrefixedApiKey.generate(" acme ")
    end

    test "returns a generated PrefixedAPIKey containing a short 8 character token" do
      {:ok, %PrefixedApiKey{short_token: short}} = PrefixedApiKey.generate("mimoto")
      assert String.length(short) == 8
    end

    test "returns a generated PrefixedAPIKey containing a 24 character long token" do
      {:ok, %PrefixedApiKey{long_token: long}} = PrefixedApiKey.generate("digitalidentity")
      assert String.length(long) == 24
    end

    test "returns a generated PrefixedAPIKey containing a hashed long token" do
      {:ok, prefixed_api_key} = PrefixedApiKey.generate("mimoto")
      assert String.length(prefixed_api_key.hash) == 64
    end

    test "returns a generated PrefixedAPIKey containing an api key string in the correct format" do
      {:ok, prefixed_api_key} = PrefixedApiKey.generate("mimoto")
      assert prefixed_api_key.api_key =~ ~r/^(?<prefix>[a-zA-Z0-9]+)_(?<short>[a-zA-Z0-9]{8})_(?<long>[a-zA-Z0-9]{24})$/
    end

  end

  describe "parse/1" do

    test "returns a PrefixedAPIKey struct in an OK tuple when passed a valid string" do
      {:ok, key} = PrefixedApiKey.parse("indiid_ZplVTncO_TCX0ZQp3XBs1fS2D2DBPDlsH")
      assert key == %PrefixedApiKey{
               api_key: "indiid_ZplVTncO_TCX0ZQp3XBs1fS2D2DBPDlsH",
               hash: "41a6dbbdc6cbe970ccc95863c18de6b943b7f467010ae86dd0172c35c2e2e9eb",
               long_token: "TCX0ZQp3XBs1fS2D2DBPDlsH",
               prefix: "indiid",
               short_token: "ZplVTncO"
             }
    end

    test "returns an error message in an error tuple when passed an invalid string" do
      assert {:error, "Cannot extract token information from the API key"} == PrefixedApiKey.parse("wro.ng_ZplVTncOX_XXXXXTCX0ZQp3XBs1fS2D2DBPDlsH")
    end

    test "returns a PrefixedAPIKey struct in an OK tuple when passed a valid PrefixedAPIKey struct (pass-through)" do
      {:ok, input_key} = PrefixedApiKey.generate("example")
      {:ok, output_key} = PrefixedApiKey.parse(input_key)
      assert output_key.api_key == input_key.api_key
    end

  end

  describe "verify/2" do

    test "returns true when passed an API key string and a matching hash" do
      assert PrefixedApiKey.verify?("indiid_ZplVTncO_TCX0ZQp3XBs1fS2D2DBPDlsH", "41a6dbbdc6cbe970ccc95863c18de6b943b7f467010ae86dd0172c35c2e2e9eb")
    end

    test "returns false when passed an API key string and an mismatched hash" do
      refute PrefixedApiKey.verify?("indiid_ZplVTncO_TCX0ZQp3XBs1fS2D2DBPDlsH", "41a6cbbdc6cbe970ccc95863c18de6b943b7f467010ae86dd0172c35c2e2e9eb")
    end

    test "returns false when passed an API key string and a completely invalid hash string" do
      refute PrefixedApiKey.verify?("indiid_ZplVTncO_TCX0ZQp3XBs1fS2D2DBPDlsH", "We're just normal men ... just innocent men")
    end

    test "returns false when passed a completely nonsensical string that's nothing like the right format" do
      refute PrefixedApiKey.verify?("HonkHonkHonk", "41a6cbbdc6cbe970ccc95863c18de6b943b7f467010ae86dd0172c35c2e2e9eb")
    end

  end

  describe "verify/3" do

    test "returns true when passed an API key string and a matching hash and correct short token" do
      assert PrefixedApiKey.verify?("indiid_ZplVTncO_TCX0ZQp3XBs1fS2D2DBPDlsH", "41a6dbbdc6cbe970ccc95863c18de6b943b7f467010ae86dd0172c35c2e2e9eb", "ZplVTncO")
    end

    test "returns false when passed an API key string and an mismatched hash and correct short token" do
      refute PrefixedApiKey.verify?("indiid_ZplVTncO_TCX0ZQp3XBs1fS2D2DBPDlsH", "41a6cbbdc6cbe970ccc95863c18de6b943b7f467010ae86dd0172c35c2e2e9eb", "ZplVTncO")
    end

    test "returns false when passed an API key string and a completely invalid hash string and correct short token" do
      refute PrefixedApiKey.verify?("indiid_ZplVTncO_TCX0ZQp3XBs1fS2D2DBPDlsH", "We're just normal men ... just innocent men", "ZplVTncO")
    end

    test "returns false when passed a completely nonsensical string that's nothing like the right format and correct short token" do
      refute PrefixedApiKey.verify?("HonkHonkHonk", "41a6cbbdc6cbe970ccc95863c18de6b943b7f467010ae86dd0172c35c2e2e9eb", "ZplVTncO")
    end

    test "returns false when passed an API key string and a matching hash but an incorrect short token" do
      refute PrefixedApiKey.verify?("indiid_ZplVTncO_TCX0ZQp3XBs1fS2D2DBPDlsH", "41a6dbbdc6cbe970ccc95863c18de6b943b7f467010ae86dd0172c35c2e2e9eb", "ZplVTncX")
    end

  end

end
