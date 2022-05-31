defmodule PrefixedApiKeyTest do
  use ExUnit.Case
  doctest PrefixedApiKey

  describe "generate/1" do

    test "returns a PrefixedApiKey structure in result tuple" do

    end

    test "returns an error when passed an invalid prefix" do

    end

    test "returns a generated PrefixedAPIKey containing the normalised prefix" do

    end

    test "returns a generated PrefixedAPIKey containing a short token" do

    end

    test "returns a generated PrefixedAPIKey containing a long token" do

    end

    test "returns a generated PrefixedAPIKey containing a hashed long token" do

    end

    test "returns a generated PrefixedAPIKey containing an api key string" do

    end

  end

  describe "parse/1" do

    test "returns a PrefixedAPIKey struct in an OK tuple when passed a valid string" do

    end

    test "returns an error message in an error tuple when passed an invalid string" do

    end

    test "returns a PrefixedAPIKey struct in an OK tuple when passed a valid PrefixedAPIKey struct (pass-through)" do

    end

  end

  describe "valid?/2" do

    test "returns true when passed an API key string and a matching hash" do

    end

    test "returns false when passed an API key string and an mismatched hash" do

    end

    test "returns false when passed an API key string and a completely invalid hash string" do

    end

    test "returns false when passed a completely nonsensical string that's nothing like the right format" do

    end

  end

  describe "valid?/3" do


  end

end
