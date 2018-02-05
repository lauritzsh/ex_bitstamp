defmodule ExBitstamp.ApiClient do
  alias ExBitstamp.{CurrencyPair, Credentials}

  defmacro __using__(apis) do
    quote bind_quoted: [apis: apis] do
      Enum.each(apis, fn {function_name, url, access, function_details} ->
        Enum.each(function_details, fn params ->
          {url, params} =
            case params do
              {:v2, params} -> {"v2/#{url}", params}
              params when is_list(params) -> {url, params}
            end
          if :currency_pair in params do
            def unquote(function_name)(%CurrencyPair{} = currency_pair) do
              unquote(function_name)(lookup_client_pid(), currency_pair)
            end

            def unquote(function_name)(pid, %CurrencyPair{} = currency_pair) when is_pid(pid) do
              GenServer.call(pid, {unquote(function_name), currency_pair})
            end

            def handle_call({unquote(function_name), %CurrencyPair{from: from, to: to}}, _, state) do
              {:reply, get("#{unquote(url)}/#{format_currency_pair(from, to)}/"), state}
            end
          end

          if :currency_pair in params and :params in param do
            def unquote(function_name)(%CurrencyPair{} = currency_pair, params) when is_list(params) do
              unquote(function_name)(lookup_client_pid(), currency_pair, params)
            end

            def unquote(function_name)(pid, %CurrencyPair{} = currency_pair, params) when is_pid(pid) and is_list(params) do
              GenServer.call(pid, {unquote(function_name), currency_pair, params})
            end

            def handle_call({unquote(function_name), %CurrencyPair{from: from, to: to}, params}, _, state) do
              {:reply, get("#{unquote(url)}/#{format_currency_pair(from, to)}/"), state}
            end
          end
        end)
      end)
    end
  end

  defp api_request(uri, type, params, opts) do

  end

  def handle_call({uri, type, params, opts}) do
    #get or post
  end

  def lookup_client_pid()
end