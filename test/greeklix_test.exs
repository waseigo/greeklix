defmodule GreeklixTest do
  use ExUnit.Case
  doctest Greeklix

  test "greets the world" do
    assert Greeklix.hello() == :world
  end
end
