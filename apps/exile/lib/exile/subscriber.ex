defmodule Exile.Subscriber do
  @moduledoc """
  A subscriber is a reference to which messages containing events
  will be sent pertaining to the `Exile.Path` which have been
  subscribed to.
  """

  @typedoc "Address of subscriber"
  @type t() :: pid() | atom()
end
