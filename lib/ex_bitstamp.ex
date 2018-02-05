defmodule ExBitstamp do
  use GenServer

  alias ExBitstamp.{CurrencyPair, Credentials}

  @default_name :bitstamp_client
  @endpoint "https://www.bitstamp.net/api"

  def start_link(name \\ @default_name, creds \\ nil) do
    creds =
      case creds do
        %Credentials{} ->
          creds

        _ ->
          %Credentials{
            key: Application.get_env(:ex_bitstamp, :creds).key,
            secret: Application.get_env(:ex_bitstamp, :creds).secret,
            customer_id: Application.get_env(:ex_bitstamp, :creds).customer_id
          }
      end

    GenServer.start_link(__MODULE__, %{creds: creds, name: name}, name: via_tuple(name))
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

  defp get_pid(pid) when is_pid(pid), do: pid

  defp get_pid(nil), do: lookup_client_pid()

  defp get_pid(name), do: lookup_client_pid(name)

  def ticker(%CurrencyPair{} = currency_pair, pid_or_name \\ nil),
    do: GenServer.call(get_pid(pid_or_name), {:public, :ticker, currency_pair, [], :v2})

  def ticker_hour(%CurrencyPair{} = currency_pair, pid_or_name \\ nil),
    do: GenServer.call(get_pid(pid_or_name), {:public, :ticker_hour, currency_pair, [], :v2})

  def order_book(%CurrencyPair{} = currency_pair, pid_or_name \\ nil),
    do: GenServer.call(get_pid(pid_or_name), {:public, :order_book, currency_pair, [], :v2})

  def transactions(%CurrencyPair{} = currency_pair, opts \\ [], pid_or_name \\ nil),
    do: GenServer.call(get_pid(pid_or_name), {:public, :transactions, currency_pair, opts, :v2})

  def trading_pairs_info(pid_or_name \\ nil),
    do: GenServer.call(get_pid(pid_or_name), {:public, :trading_pairs_info, [], :v2})

  def balance(%CurrencyPair{} = currency_pair, pid_or_name \\ nil),
    do: GenServer.call(get_pid(pid_or_name), {:private, :balance, currency_pair, [], :v2})

  def user_transactions(%CurrencyPair{} = currency_pair, pid_or_name \\ nil),
    do:
      GenServer.call(get_pid(pid_or_name), {:private, :user_transactions, currency_pair, [], :v2})

  def open_orders(%CurrencyPair{} = currency_pair, pid_or_name \\ nil),
    do: GenServer.call(get_pid(pid_or_name), {:private, :open_orders, currency_pair, [], :v2})

  def order_status(id, pid_or_name \\ nil),
    do: GenServer.call(get_pid(pid_or_name), {:private, :order_status, [id: id], :v1})

  def cancel_order(id, pid_or_name \\ nil),
    do: GenServer.call(get_pid(pid_or_name), {:private, :cancel_order, [id: id], :v2})

  def cancel_all_orders(pid_or_name \\ nil),
    do: GenServer.call(get_pid(pid_or_name), {:private, :cancel_all_orders, [], :v1})

  def buy(%CurrencyPair{} = currency_pair, amount, price, opts \\ [], pid_or_name \\ nil)
      when is_list(opts),
      do:
        GenServer.call(
          get_pid(pid_or_name),
          {:private, :buy, currency_pair, opts ++ [amount: amount, price: price], :v2}
        )

  def buy_market(%CurrencyPair{} = currency_pair, amount, pid_or_name \\ nil),
    do:
      GenServer.call(
        get_pid(pid_or_name),
        {:private, :buy_market, currency_pair, [amount: amount], :v2}
      )

  def sell(%CurrencyPair{} = currency_pair, amount, price, opts \\ [], pid_or_name \\ nil)
      when is_list(opts),
      do:
        GenServer.call(
          get_pid(pid_or_name),
          {:private, :sell, currency_pair, [amount: amount, price: price], :v2}
        )

  def sell_market(%CurrencyPair{} = currency_pair, amount, pid_or_name \\ nil),
    do:
      GenServer.call(
        get_pid(pid_or_name),
        {:private, :sell_market, currency_pair, [amount: amount]}
      )

  def withdrawal_requests(opts \\ [], pid_or_name \\ nil) when is_list(opts),
    do: GenServer.call(get_pid(pid_or_name), {:private, :withdrawal_requests, opts})

  def btc_withdrawal(amount, address, instant, pid_or_name \\ nil),
    do: coin_withdrawal(pid_or_name, :btc_withdrawal, amount, address, [instant: instant], :v1)

  def ltc_withdrawal(amount, address, pid_or_name \\ nil),
    do: coin_withdrawal(pid_or_name, :ltc_withdrawal, amount, address)

  def eth_withdrawal(amount, address, pid_or_name \\ nil),
    do: coin_withdrawal(pid_or_name, :eth_withdrawal, amount, address)

  def xrp_withdrawal(amount, address, destination_tag, pid_or_name \\ nil),
    do:
      coin_withdrawal(
        pid_or_name,
        :xrp_withdrawal,
        amount,
        address,
        destination_tag: destination_tag
      )

  def bch_withdrawal(amount, address, pid_or_name \\ nil),
    do: coin_withdrawal(pid_or_name, :bch_withdrawal, amount, address)

  defp coin_withdrawal(pid_or_name, endpoint, amount, address, opts \\ [], version \\ :v2),
    do:
      GenServer.call(
        get_pid(pid_or_name),
        {:private, endpoint, opts ++ [amount: amount, address: address], version}
      )

  def btc_deposit_address(pid_or_name \\ nil),
    do: coin_deposit_address(pid_or_name, :btc_address, :v1)

  def ltc_deposit_address(pid_or_name \\ nil), do: coin_deposit_address(pid_or_name, :ltc_address)

  def eth_deposit_address(pid_or_name \\ nil), do: coin_deposit_address(pid_or_name, :eth_address)

  def xrp_deposit_address(pid_or_name \\ nil), do: coin_deposit_address(pid_or_name, :xrp_address)

  def bch_deposit_address(pid_or_name \\ nil), do: coin_deposit_address(pid_or_name, :bch_address)

  defp coin_deposit_address(pid_or_name, endpoint, version \\ :v2),
    do: GenServer.call(get_pid(pid_or_name), {:private, endpoint, [], version})

  def handle_call({:public, endpoint, opts, version}, _, state),
    do: {:reply, get("#{version(version)}#{segment(endpoint)}/", [], params: opts), state}

  def handle_call({:public, endpoint, %CurrencyPair{from: from, to: to}, opts, version}, _, state) do
    uri = "#{version(version)}/#{segment(endpoint)}/#{currency_pair_segment(from, to)}/"
    {:reply, get(uri, [], params: opts), state}
  end

  def handle_call({:private, endpoint, opts, version}, _, %{creds: creds} = state),
    do:
      {:reply, post("#{version(version)}#{segment(endpoint)}/", opts ++ signature(creds)), state}

  def handle_call(
        {:private, endpoint, %CurrencyPair{from: from, to: to}, opts, version},
        _,
        %{creds: creds} = state
      ) do
    uri = "#{version(version)}#{segment(endpoint)}/#{currency_pair_segment(from, to)}/"
    {:reply, post(uri, opts ++ signature(creds)), state}
  end

  defp get(uri, headers \\ [], options \\ []) do
    case HTTPoison.get("#{@endpoint}/#{uri}", headers, options) do
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

  defp encrypt_hmac_sha256(message, key), do: :crypto.hmac(:sha256, key, message)

  defp version(:v1), do: ""

  defp version(:v2), do: "v2/"

  defp segment(:sell_market), do: "sell/market"

  defp segment(:buy_market), do: "buy/market"

  defp segment(:trading_pairs_info), do: "trading-pairs-info"

  defp segment(:btc_withdrawal), do: "bitcoin_withdrawal"

  defp segment(:btc_address), do: "bitcoin_address"

  defp segment(action), do: Atom.to_string(action)

  defp currency_pair_segment(from, to), do: String.downcase(from <> to)
end
