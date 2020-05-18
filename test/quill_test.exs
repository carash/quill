defmodule QuillTest do
  use ExUnit.Case
  doctest Quill

  test "greets the world" do
    assert Quill.hello() == :world
  end
end
