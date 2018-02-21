defmodule ExBitstamp.Credentials do
  @moduledoc """
  Provides a struct for API credentials.
  """

  alias __MODULE__

  @type t :: %Credentials{customer_id: String.t(), key: String.t(), secret: String.t()}

  @enforce_keys [:customer_id, :key, :secret]
  defstruct [:customer_id, :key, :secret]
end
