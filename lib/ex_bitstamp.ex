defmodule ExBitstamp do
  use GenServer
  use ExBitstamp.ApiClient, [
    {:ticker, "ticker", :public, [[], {:v2, [:currency_pair]}]},
    {:ticker_hour, "ticker_hour", :public, [[], {:v2, [:currency_pair]}]},
    {:order_book, "order_book", :public, [[], {:v2, [:currency_pair]}]},
    {:transactions, "transactions", :public, [[:params], {:v2, [:currency_pair, :params]}]},
  ]

  alias ExBitstamp.{CurrencyPair, Credentials}

  @default_name :bitstamp_client
  @endpoint "https://www.bitstamp.net/api"

  def start_link(name, creds) do
    GenServer.start_link(__MODULE__, %{creds: creds, name: name}, name: via_tuple(name))
  end

  def start_link() do
    creds = %Credentials{
      key: Application.get_env(:ex_bitstamp, :creds).key,
      secret: Application.get_env(:ex_bitstamp, :creds).secret,
      customer_id: Application.get_env(:ex_bitstamp, :creds).customer_id
    }

    start_link(@default_name, creds)
  end

  def init(state) do
    {:ok, state}
  end

  def lookup_client(name \\ @default_name), do: Registry.lookup(Registry.ExBitstamp, name)

  def lookup_client_pid(name \\ @default_name) do
    case lookup_client() do
      [{pid, value}] -> pid
      [] -> nil
    end
  end

  def via_tuple(name \\ @default_name), do: {:via, Registry, {Registry.ExBitstamp, name}}

  #def ticker(), do: ticker(lookup_client_pid())

  #def ticker(pid) when is_pid(pid), do: GenServer.call(pid, {:ticker})

  #def ticker(%CurrencyPair{} = currency_pair), do: ticker(lookup_client_pid(), currency_pair)

  #def ticker(pid, %CurrencyPair{} = currency_pair) when is_pid(pid),
    #do: GenServer.call(pid, {:ticker, currency_pair})

  #def hourly_ticker(ex_bitstamp), do: GenServer.call(ex_bitstamp, {:hourly_ticker})

  #def hourly_ticker(%CurrencyPair{} = currency_pair),
    #do: GenServer.call(__MODULE__, {:hourly_ticker, currency_pair})

  #def order_book(), do: GenServer.call(__MODULE__, {:order_book})

  #def order_book(%CurrencyPair{} = currency_pair),
    #do: GenServer.call(__MODULE__, {:order_book, currency_pair})

  #def transactions(), do: GenServer.call(__MODULE__, {:transactions})

  #def transactions(%CurrencyPair{} = currency_pair),
    #do: GenServer.call(__MODULE__, {:transactions, currency_pair})

  def transactions_query(params) when is_list(params),
    do: GenServer.call(__MODULE__, {:transactions, params})

  def transactions_query(%CurrencyPair{} = currency_pair, params) when is_list(params),
    do: GenServer.call(__MODULE__, {:transactions, currency_pair, params})

  def trading_pairs_info(), do: GenServer.call(__MODULE__, {:trading_pairs_info})

  def balance(), do: GenServer.call(lookup_client_pid(), {:balance})

  def balance(%CurrencyPair{} = currency_pair),
    do: GenServer.call(__MODULE__, {:balance, currency_pair})

  def user_transactions(), do: GenServer.call(__MODULE__, {:user_transactions})

  def user_transactions(%CurrencyPair{} = currency_pair),
    do: GenServer.call(__MODULE__, {:user_transactions, currency_pair})

  def user_transactions_query(params) when is_list(params),
    do: GenServer.call(__MODULE__, {:user_transactions, params})

  def user_transactions(%CurrencyPair{} = currency_pair, params) when is_list(params),
    do: GenServer.call(__MODULE__, {:user_transactions, currency_pair, params})

  def open_orders(), do: GenServer.call(__MODULE__, {:open_orders})

  def open_orders(%CurrencyPair{} = currency_pair),
    do: GenServer.call(__MODULE__, {:open_orders, currency_pair})

  def order_status(id), do: GenServer.call(__MODULE__, {:order_status, id})

  def cancel_order(id), do: GenServer.call(__MODULE__, {:cancel_order, id})

  def cancel_all_orders(), do: GenServer.call(__MODULE__, {:cancel_all_orders})

  def buy(amount, price, %CurrencyPair{} = currency_pair \\ nil, opts \\ []) when is_list(opts),
    do: GenServer.call(__MODULE__, {:buy, currency_pair, amount, price, opts})

  def buy_market(%CurrencyPair{} = currency_pair, amount),
    do: GenServer.call(__MODULE__, {:buy_market, currency_pair, amount})

  def sell(amount, price, %CurrencyPair{} = currency_pair \\ nil, opts \\ []) when is_list(opts),
    do: GenServer.call(__MODULE__, {:sell, currency_pair, amount, price, opts})

  def sell_market(%CurrencyPair{} = currency_pair, amount),
    do: GenServer.call(__MODULE__, {:sell_market, currency_pair, amount})

  def withdrawal_requests(opts \\ []) when is_list(opts),
    do: GenServer.call(__MODULE__, {:withdrawal_requests, opts})

  def btc_withdrawal(amount, address, instant),
    do: coin_withdrawal("bitcoin", amount, address, instant: instant)

  def ltc_withdrawal(amount, address),
    do: coin_withdrawal("v2/ltc", amount, address)

  def eth_withdrawal(amount, address),
    do: coin_withdrawal("v2/eth", amount, address)

  def xrp_withdrawal(amount, address, destination_tag),
    do: coin_withdrawal("v2/xrp", amount, address, destination_tag: destination_tag)

  def bch_withdrawal(amount, address),
    do: coin_withdrawal("v2/bch", amount, address)

  defp coin_withdrawal(coin_uri, amount, address, opts \\ []),
    do: GenServer.call(__MODULE__, {:coin_withdrawal, coin_uri, amount, address, opts})

  def btc_deposit_address(), do: coin_deposit_address("bitcoin")

  def ltc_deposit_address(), do: coin_deposit_address("v2/ltc")

  def eth_deposit_address(), do: coin_deposit_address("v2/eth")

  def xrp_deposit_address(), do: coin_deposit_address("v2/xrp")

  def bch_deposit_address(), do: coin_deposit_address("v2/bch")

  defp coin_deposit_address(coin_uri),
    do: GenServer.call(__MODULE__, {:coin_deposit_address, coin_uri})

  def handle_call({:trading_pairs_info}, _, state),
    do: {:reply, get("v2/trading-pairs-info/"), state}

  def handle_call({:balance}, _, %{creds: creds} = state),
    do: {:reply, post("v2/balance/", signature(creds)), state}

  def handle_call({:balance, %CurrencyPair{from: from, to: to}}, _, %{creds: creds} = state),
    do: {:reply, post("v2/balance/#{format_currency_pair(from, to)}/", signature(creds)), state}

  def handle_call({:user_transactions}, _, %{creds: creds} = state),
    do: {:reply, post("v2/user-transactions/", signature(creds)), state}

  def handle_call(
        {:user_transactions, %CurrencyPair{from: from, to: to}},
        _,
        %{creds: creds} = state
      ),
      do:
        {:reply,
         post("v2/user-transactions/#{format_currency_pair(from, to)}/", signature(creds)), state}

  def handle_call({:user_transactions, params}, _, %{creds: creds} = state),
    do: {:reply, post("v2/user-transactions/", params ++ signature(creds)), state}

  def handle_call(
        {:user_transactions, %CurrencyPair{from: from, to: to}, params},
        _,
        %{creds: creds} = state
      ),
      do:
        {:reply,
         post(
           "v2/user-transactions/#{format_currency_pair(from, to)}/",
           params ++ signature(creds)
         ), state}

  def handle_call({:open_orders}, _, %{creds: creds} = state),
    do: {:reply, post("v2/open-orders/", signature(creds)), state}

  def handle_call({:open_orders, %CurrencyPair{from: from, to: to}}, _, %{creds: creds} = state),
    do: {:reply, post("v2/open-orders/#{format_currency_pair(from, to)}/", signature(creds)), state}

  def handle_call({:order_status, id}, _, %{creds: creds} = state),
    do: {:reply, post("/order-status/", [id: id] ++ signature(creds)), state}

  def handle_call({:cancel_order, id}, _, %{creds: creds} = state),
    do: {:reply, post("/cancel-order/", [id: id] ++ signature(creds)), state}

  def handle_call({:cancel_all_orders}, _, %{creds: creds} = state),
    do: {:reply, post("/cancel-all-order/", signature(creds)), state}

  def handle_call({:buy, currency_pair, amount, price, opts}, _, %{creds: creds} = state) do
    params = [amount: amount, price: price] ++ opts ++ signature(creds)
    case currency_pair do
      nil ->
        {:reply, post("/buy/", params), state}

      %CurrencyPair{from: from, to: to} ->
        {:reply, post("/v2/buy/#{format_currency_pair(from, to)}/", params), state}
    end
  end

  def handle_call({:buy_market, %CurrencyPair{from: from, to: to}, amount}, _, %{creds: creds} = state) do
    params = [amount: amount] ++ signature(creds)
    {:reply, post("/v2/buy/market/#{format_currency_pair(from, to)}/", params), state}
  end

  def handle_call({:sell, currency_pair, amount, price, opts}, _, %{creds: creds} = state) do
    params = [amount: amount, price: price] ++ opts ++ signature(creds)
    case currency_pair do
      nil ->
        {:reply, post("/sell/", params), state}

      %CurrencyPair{from: from, to: to} ->
        {:reply, post("/v2/sell/#{format_currency_pair(from, to)}/", params), state}
    end
  end

  def handle_call({:sell_market, %CurrencyPair{from: from, to: to}, amount}, _, %{creds: creds} = state) do
    params = [amount: amount] ++ signature(creds)
    {:reply, post("/v2/sell/market/#{format_currency_pair(from, to)}/", params), state}
  end

  def handle_call({:withdrawal_requests, opts}, _, %{creds: creds} = state) do
    params = opts ++ signature(creds)
    {:reply, post("/v2/withdrawal-requests/", params), state}
  end

  def handle_call({:coin_withdrawal, coin_uri, amount, address, opts}, _, %{creds: creds} = state) do
    params = [amount: amount, address: address] ++ opts ++ signature(creds)
    {:reply, post("/#{coin_uri}_withdrawal/", params), state}
  end

  def handle_call({:coin_deposit_address, coin_uri}, _, %{creds: creds} = state),
    do: {:reply, post("/#{coin_uri}_address/", signature(creds)), state}

  defp get(uri, headers \\ [], options \\ []) do
    IO.inspect uri
    case HTTPoison.get("#{@endpoint}/#{uri}", headers, options) do
      {:error, reason} ->
        {:error, {:http_error, reason}}

      {:ok, response} ->
        IO.inspect response
        case Poison.decode(response.body) do
          {:ok, data} -> {:ok, data}
          {:error, reason} -> {:error, {:poison_decode_error, reason}}
          {:error, reason, _code} -> {:error, {:poison_decode_error, reason}}
        end
    end
  end

  defp post(uri, data) do
    case HTTPoison.post("#{@endpoint}/#{uri}", {:form, data}) do
      {:error, reason} ->
        {:error, {:http_error, reason}}

      {:ok, response} ->
        case Poison.decode(response.body) do
          {:ok, data} -> {:ok, data}
          {:error, reason} -> {:error, {:poison_decode_error, reason}}
          {:error, reason, _code} -> {:error, {:poison_decode_error, reason}}
        end
    end
  end

  defp signature(%{key: key, secret: secret, customer_id: customer_id}) do
    nonce = :os.system_time(:millisecond)

    signature =
      "#{nonce}#{customer_id}#{key}"
      |> encrypt_hmac_sha256(secret)
      |> Base.encode16()

    [key: key, nonce: nonce, signature: signature]
  end

  defp encrypt_hmac_sha256(message, key) do
    :crypto.hmac(:sha256, key, message)
  end

  defp format_currency_pair(from, to), do: String.downcase(from <> to)
end
