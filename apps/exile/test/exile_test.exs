defmodule ExileTest do
  use ExUnit.Case, async: false

  describe "post" do
    test "should create a new record" do
      json = """
      {
        "author": "holsee",
        "tags": ["bill", "ted", "rufus"],
        "comments": []
      }
      """

      post = Jason.decode!(json)
      assert {:ok, post_id} = Exile.post("posts", post)
    after
      Exile.delete("posts")
    end

    test "should add new record to existing nested list" do
      json = """
      {
        "author": "holsee",
        "tags": ["bill", "ted", "rufus"],
        "comments": []
      }
      """

      post = Jason.decode!(json)
      assert {:ok, post_id} = Exile.post("posts", post)

      json = """
      {
        "author": "bran",
        "body": "Lorem ipsum"
      }
      """

      comment = Jason.decode!(json)
      assert {:ok, comment_id} = Exile.post("posts/#{post_id}/comments", comment)
      assert {:ok, [%{id: comment_id, value: value}]} = Exile.get("posts/#{post_id}/comments")

      assert {:ok, ^comment} = Exile.get("posts/#{post_id}/comments/#{comment_id}")
    after
      Exile.delete("posts")
    end

    test "should return :unsupported_operation when path does not exist to point of creation" do
      json = """
      {
        "author": "bran",
        "body": "Lorem ipsum"
      }
      """

      comment = Jason.decode!(json)

      assert {:error, :unsupported_operation} = Exile.post("foos/bars/", comment)
    after
      Exile.delete("posts")
    end

    test "should return :unsupported_operation when trying to post to existing attribute" do
      json = """
      {
        "author": "holsee",
        "tags": ["bill", "ted", "rufus"],
        "comments": []
      }
      """

      post = Jason.decode!(json)
      assert {:ok, post_id} = Exile.post("posts", post)

      assert {:error, :unsupported_operation} =
               Exile.post("posts/#{post_id}/author", "someone_else")
    after
      Exile.delete("posts")
    end
  end

  describe "put" do
    test "should update an existing attribute on a record" do
      json = """
      {
        "author": "holsee",
        "tags": ["bill", "ted", "rufus"],
        "comments": []
      }
      """

      post = Jason.decode!(json)
      assert {:ok, post_id} = Exile.post("posts", post)
      assert :ok = Exile.put("posts/#{post_id}/author", "evadne")
      assert {:ok, "evadne"} = Exile.get("posts/#{post_id}/author")
    after
      Exile.delete("posts")
    end

    test "should set non-existent attributes" do
      json = """
      {
        "author": "holsee",
        "tags": ["bill", "ted", "rufus"],
        "comments": []
      }
      """

      post = Jason.decode!(json)
      assert {:ok, post_id} = Exile.post("posts", post)
      assert {:error, :not_found} = Exile.get("posts/#{post_id}/something_new")
      assert :ok = Exile.put("posts/#{post_id}/something_new", "new_attr_value")
      assert {:ok, "new_attr_value"} = Exile.get("posts/#{post_id}/something_new")
    after
      Exile.delete("posts")
    end
  end

  describe "delete" do
    test "should remove item" do
      json = """
      {
        "author": "holsee",
        "tags": ["bill", "ted", "rufus", "beethoven"],
        "comments": []
      }
      """

      post = Jason.decode!(json)
      assert {:ok, post_id} = Exile.post("posts", post)
      assert :ok = Exile.delete("posts/#{post_id}")
      assert {:error, :not_found} = Exile.get("posts/#{post_id}")
      assert {:error, :not_found} = Exile.get("posts")
    after
      Exile.delete("posts")
    end

    test "should set attribute to :deleted making it return :not_found" do
      json = """
      {
        "author": "holsee",
        "tags": ["bill", "ted", "rufus", "beethoven"],
        "comments": []
      }
      """

      post = Jason.decode!(json)
      assert {:ok, post_id} = Exile.post("posts", post)
      assert :ok = Exile.delete("posts/#{post_id}/author")
      assert {:error, :not_found} = Exile.get("posts/#{post_id}/author")
    after
      Exile.delete("posts")
    end
  end

  describe "get" do
    test "should return list items" do
      json = """
      {
        "author": "holsee",
        "tags": ["bill", "ted", "rufus", "beethoven"],
        "comments": []
      }
      """

      post = Jason.decode!(json)
      assert {:ok, post_id} = Exile.post("posts", post)
      assert {:ok, [%{id: ^post_id, ts: _, value: ^post}]} = Exile.get("posts")
    after
      Exile.delete("posts")
    end

    test "should return attribute value" do
      json = """
      {
        "author": "holsee",
        "tags": ["bill", "ted", "rufus", "beethoven"],
        "comments": []
      }
      """

      post = Jason.decode!(json)
      assert {:ok, post_id} = Exile.post("posts", post)
      assert {:ok, "holsee"} = Exile.get("posts/#{post_id}/author")
    after
      Exile.delete("posts")
    end

    test "should return :not_found if path has no record" do
      assert {:error, :not_found} = Exile.get("void")
    after
      Exile.delete("posts")
    end
  end

  describe "subscribe" do
    test "should subscribe to change events on record" do
      subscriber =
        Task.async(fn ->
          receive do
            msg -> msg
          end
        end)

      :ok = Exile.subscribe("posts", subscriber.pid)

      json = """
      {
        "author": "holsee",
        "tags": ["bill", "ted", "rufus", "beethoven"],
        "comments": []
      }
      """

      post = Jason.decode!(json)
      path = "posts"
      assert {:ok, post_id} = Exile.post(path, post)

      assert {:exile_event, {:new, ^path, {_id, _ts, ^post}}} = Task.await(subscriber)
    end
  end

end
