defmodule ExileWeb.StoreController do
  use ExileWeb, :controller

  def get(conn, %{"path" => path}) do
    epath = exile_path(path)
    case Exile.get(epath) do
      {:ok, data} ->
        conn
        |> put_status(200)
        |> put_resp_content_type("application/json")
        |> json(data)
      {:error, :not_found} ->
        conn
        |> send_resp(404, "Resource at path #{epath} not found")
    end
  end

  def post(conn, %{"path" => path} = params) do
    epath = exile_path(path)
    case Exile.post(epath, Map.drop(params, ["path"])) do
      {:ok, _} ->
        send_resp(conn, 200, "Successfully posted to path #{epath}")
      {:error, reason} ->
        send_resp(conn, 400, "Could not post due to reason: #{reason}")
    end
  end

  def delete(conn, %{"path" => path} = params) do
    epath = exile_path(path)
    case Exile.delete(epath, Map.drop(params, ["path"])) do
      {:ok, _} ->
        send_resp(conn, 200, "Successfully deleted data at path #{epath}")
      {:error, :not_found} ->
        send_resp(conn, 404, "Resource at path #{epath} not found")
    end
  end

  def put(conn, %{"path" => path} = params) do
    epath = exile_path(path)
    case Exile.put(epath, Map.drop(params, ["path"])) do
      {:ok, _} ->
        send_resp(conn, 200, "Successfully updated data at path #{epath}")
      {:error, :not_found} ->
        send_resp(conn, 404, "Resource at path #{epath} not found")
    end
  end

  # Takes list of path items and joins into a path for Exile to digest
  defp exile_path(path), do: Enum.join(path, "/")
end
