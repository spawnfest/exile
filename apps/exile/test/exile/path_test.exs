defmodule Exile.PathTest do
  use ExUnit.Case

  describe "to_ref" do
    test "should return root elemenet of path" do
      assert "foo" == Exile.Path.to_ref("/foo/bar")
      assert "foo" == Exile.Path.to_ref("foo/bar")
      assert "foo" == Exile.Path.to_ref("foo")
    end
  end
end
