defmodule ExileWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ChannelTest
      @endpoint ExileWeb.Endpoint
    end
  end

  setup _tags do
    :ok
  end
end
