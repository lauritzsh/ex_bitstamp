defmodule ExBitstamp.Credentials do
  @enforce_keys [:customer_id, :key, :secret]
  defstruct [:customer_id, :key, :secret]
end
