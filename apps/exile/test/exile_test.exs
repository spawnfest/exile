defmodule ExileTest do
  use ExUnit.Case

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
      assert {:ok, [^comment]} = Exile.get("posts/#{post_id}/comments")
      assert {:ok, ^comment} = Exile.get("posts/#{post_id}/comments/#{comment_id}")
    end

    test "should return :non_existant_path when path does not exist to point of creation" do
      json = """
      {
        "author": "bran",
        "body": "Lorem ipsum"
      }
      """

      comment = Jason.decode!(json)

      assert {:ok, :non_existant_path} = Exile.post("foos/bars/", comment)
    end

    test "should return :cannot_create_record_on_attribute when trying to post to existing attribute" do
      json = """
      {
        "author": "holsee",
        "tags": ["bill", "ted", "rufus"],
        "comments": []
      }
      """

      post = Jason.decode!(json)
      assert {:ok, post_id} = Exile.post("posts", post)

      assert :cannot_create_record_on_attribute =
               Exile.post("posts/#{post_id}/author", "someone_else")
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
      assert :ok = Exile.put("posts/#{post_id}/author", "evande")
      assert "evadne" = Exile.get("posts/#{post_id}/author")
    end

    test "should return not found if trying to set non-existent attribute" do
      json = """
      {
        "author": "holsee",
        "tags": ["bill", "ted", "rufus"],
        "comments": []
      }
      """

      post = Jason.decode!(json)
      assert {:ok, post_id} = Exile.post("posts", post)
      assert {:error, :not_found} = Exile.put("posts/#{post_id}/something_else", "evande")
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
      assert {:ok, []} = Exile.get("posts")
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
      assert :not_found = Exile.get("posts/#{post_id}/author")
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
      assert {:ok, [^post]} = Exile.get("posts")
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
      assert {:ok, "holsee"} = Exile.get("posts")
    end

    test "should return :not_found if path has not record" do
      assert :not_found = Exile.get('void')
    end
  end
end
