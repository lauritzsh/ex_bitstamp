defmodule ExBitstamp.ApiClient do
  @moduledoc false
  use HTTPoison.Base

  def process_url(url) do
    "https://www.bitstamp.net/api" <> url
  end
end
