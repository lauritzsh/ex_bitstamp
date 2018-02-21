defmodule ApiClientMock do
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
        {"Server", "nginx"},
        {"Date", "Thu, 21 Jul 2016 16:52:38 GMT"},
        {"Content-Type", "application/json"},
        {"Content-Length", "397"},
        {"Connection", "keep-alive"},
        {"Keep-Alive", "timeout=10"},
        {"Vary", "Accept-Encoding"},
        {"Vary", "Accept-Encoding"},
        {"X-UA-Compatible", "IE=edge"},
        {"X-Frame-Options", "deny"},
        {"Content-Security-Policy", "default-src 'self'; script-src 'self' foo"},
        {"X-Content-Security-Policy", "default-src 'self'; script-src 'self' foo"},
        {"Cache-Control", "no-cache, no-store, must-revalidate"},
        {"Pragma", "no-cache"},
        {"X-Content-Type-Options", "nosniff"},
        {"Strict-Transport-Security", "max-age=31536000;"}
      ],
      status_code: 200
    }
  end
end
