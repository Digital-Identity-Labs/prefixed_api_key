defmodule PrefixedApiKey.ShortToken do
  @moduledoc false

  use Puid, chars: :alphanum, bits: 47

  ## All the work is done by the Puid library - it provides a .generate() method
  @spec generate() :: binary()

end
