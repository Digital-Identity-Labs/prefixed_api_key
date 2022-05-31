defmodule PrefixedApiKeyTest do
  use ExUnit.Case
  doctest PrefixedApiKey

  test "greets the world" do
    assert PrefixedApiKey.hello() == :world
  end
end
