defmodule ApiClientMock do
  @moduledoc false

  def post(_url, _data, response_body) do
    {:ok, successful_response(response_body)}
  end

  def get(_url, _data, _options, response_body) do
    {:ok, successful_response(response_body)}
  end

  defp successful_response(body) do
    %HTTPoison.Response{
      body: body,
      headers: [
        {"Content-Type", "application/json"}
      ],
      status_code: 200
    }
  end
end
