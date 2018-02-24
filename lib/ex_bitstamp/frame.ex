defmodule ExBitstamp.Frame do
  @moduledoc """
  Provides a struct for currency pairs and convenience functions for pairs supported by Bitstamp API.
  """

  alias __MODULE__

  @type t :: %Frame{channel: String.t(), data: map(), event: String.t()}

  @enforce_keys [:channel, :data, :event]
  defstruct [:channel, :data, :event]
end