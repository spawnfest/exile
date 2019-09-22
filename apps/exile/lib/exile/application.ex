defmodule Exile.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = Exile.child_specs()
    Supervisor.start_link(children, strategy: :one_for_one, name: Exile.Supervisor)
  end
end
