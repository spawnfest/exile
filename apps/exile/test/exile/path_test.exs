defmodule Exile.PathTest do
  use ExUnit.Case

  describe "to_ref" do
    test "should return root elemenet of path" do
      assert "foo" == Exile.Path.to_ref("/foo/bar")
      assert "foo" == Exile.Path.to_ref("foo/bar")
      assert "foo" == Exile.Path.to_ref("foo")
    end
  end

  describe "parse" do
    test "should build paths" do
      id = Exile.Id.generate()

      cases = [
        {"/posts", [type: "posts"]},
        {"posts", [type: "posts"]},
        {"posts/#{id}", [type: "posts", id: id]},
        {"posts/#{id}/bar", [type: "posts", id: id, type: "bar"]}
      ]

      for {path, expected} <- cases do
        assert expected == Exile.Path.parse(path)
      end
    end
  end
end
