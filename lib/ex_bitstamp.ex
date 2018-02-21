defmodule ExBitstamp do
  @moduledoc """
  Wraps Bitstamp HTTP API into functions respective of public and private API endpoints.

  The `currency_pair` parameter in functions is expected to be an `ExBitstamp.CurrencyPair` struct. See module
  documentation for more info on all available convenience functions, but in short, supported currency pairs can
  be obtained by calling appropriately named functions:

      alias ExBitstamp.CurrencyPair

      ExBitstamp.ticker(CurrencyPair.btcusd())

  API call functions return successful results as a `{:ok, results}` tuple or `{:error, {error_type, reason}`
  tuple in case of an error. See respective functions' docs for examples of specific return values.

  `ExBitstamp` module uses v2 Bitstamp API endpoints whenever possible.

  Module functions which take an optional `creds` parameter hit Bitstamp's private API which requires valid
  API credentials for signature generation. By default, if no credentials are provided as an argument ExBitstamp
  will try to fetch credentials from config. Config should be defined as:

      config :ex_bitstamp,
        creds: %{
          customer_id: "customer_id",
          key: "key",
          secret: "key"
        }

  Otherwise, if credentials are provided as an argument, `ExBitstamp.Credentials` struct should be used to
  pass the credentials to functions.
  """

  alias ExBitstamp.{ApiClient, CurrencyPair, Credentials, BankWithdrawal}

  @doc """
  Fetches ticker data for a currency pair.

  Example successful response:

      {:ok,
       %{
        "ask" => "7117.11",
        "bid" => "7100.00",
        "high" => "7499.00",
        "last" => "7100.00",
        "low" => "5920.72",
        "open" => "6878.65",
        "timestamp" => "1517927052",
        "volume" => "71876.22396439",
        "vwap" => "6707.61"
      }}
  """
  @spec ticker(CurrencyPair.t()) :: tuple()
  def ticker(%CurrencyPair{} = currency_pair), do: public("/v2/ticker/#{segment(currency_pair)}/")

  @doc """
  Fetches hourly ticker data for a currency pair.

  Example successful response:

      {:ok,
        %{
         "ask" => "6905.42",
         "bid" => "6900.51",
         "high" => "7281.80",
         "last" => "6900.60",
         "low" => "6784.18",
         "open" => "7165.04",
         "timestamp" => "1517927653",
         "volume" => "4102.91186873",
         "vwap" => "7076.36"
        }}
  """
  @spec ticker_hour(CurrencyPair.t()) :: tuple()
  def ticker_hour(%CurrencyPair{} = currency_pair),
    do: public("/v2/ticker_hour/#{segment(currency_pair)}/")

  @doc """
  Fetches order book data for a currency pair.

  Example successful response:

      {:ok,
        %{
         "asks" => [
           ["7021.91", "1.11552422"],
           ["7021.92", "0.00216174"],
           ["7022.70", ...],
           [...],
           ...
         ],
         "bids" => [
           ["6867.88", "20.63509100"],
           ["6865.74", "2.94040800"],
           ["6861.31", ...],
           [...],
           ...
         ],
         "timestamp" => "1517927756"
        }}
  """
  @spec order_book(CurrencyPair.t()) :: tuple()
  def order_book(%CurrencyPair{} = currency_pair),
    do: public("/v2/order_book/#{segment(currency_pair)}/")

  @doc """
  Fetches transactions data for a currency pair.

  Accepts list of optional parameters as a keyword list. Allowed key is `time` with on of the following values:
  `"minute"`, `"hour"` (default) or `"day"`. See [Bitstamp API docs](https://www.bitstamp.net/api/#transactions)
  for more info.

  Example successful response:

      {:ok,
      [
       %{
         "amount" => "0.51879098",
         "date" => "1517928659",
         "price" => "7011.46",
         "tid" => "52902107",
         ...
       },
       %{
         "amount" => "0.23897801",
         "date" => "1517928659",
         "price" => "7011.45",
         ...
       },
       %{"amount" => "0.01480362", "date" => "1517928659", ...},
       %{"amount" => "0.04021837", ...},
       %{...},
       ...
      ]}

  """
  @spec transactions(CurrencyPair.t(), list()) :: tuple()
  def transactions(%CurrencyPair{} = currency_pair, opts \\ []),
    do: public("/v2/transactions/#{segment(currency_pair)}/", opts)

  @doc """
  Fetches trading pairs info.

  Example successful response:

      {:ok,
      [
       %{
         "base_decimals" => 8,
         "counter_decimals" => 2,
         "description" => "Litecoin / U.S. dollar",
         "minimum_order" => "5.0 USD",
         "name" => "LTC/USD",
         "trading" => "Enabled",
         "url_symbol" => "ltcusd"
       },
       %{
         "base_decimals" => 8,
         "counter_decimals" => 2,
         "description" => "Ether / U.S. dollar",
         "minimum_order" => "5.0 USD",
         "name" => "ETH/USD",
         "trading" => "Enabled",
         "url_symbol" => "ethusd"
       },
       ...
      ]}
  """
  @spec trading_pairs_info() :: tuple()
  def trading_pairs_info(), do: public("/v2/trading-pairs-info/")

  @doc """
  Fetches EUR/USD conversion rate.

  Example successful response:

      {:ok, %{"buy" => "1.235", "sell" => "1.235"}}
  """
  @spec eur_usd() :: tuple()
  def eur_usd(), do: public("/eur_usd/")

  @doc """
  Fetches account balance data for a currency pair.

  Example successful response:

      {:ok,
      %{
       "btc_available" => "0.00000000",
       "btc_balance" => "0.00000000",
       "btc_reserved" => "0.00000000",
       "fee" => 0.25,
       "usd_available" => "0.00",
       "usd_balance" => "0.00",
       "usd_reserved" => "0.00"
      }}
  """
  @spec balance(CurrencyPair.t(), Credentials.t() | nil) :: tuple()
  def balance(%CurrencyPair{} = currency_pair, creds \\ nil),
    do: private("/v2/balance/#{segment(currency_pair)}/", [], creds)

  @doc """
  Fetches account balance data for all currencies.

  Example successful response:

      {:ok,
      %{
       "xrp_reserved" => "0.00000000",
       "bcheur_fee" => "0.12",
       "ltc_balance" => "0.00000000",
       "ltcbtc_fee" => "0.25",
       "btc_balance" => "0.00000000",
       "ltc_reserved" => "0.00000000",
       "eth_balance" => "0.39706665",
       "eur_available" => "0.00",
       "xrpbtc_fee" => "0.25",
       "bchusd_fee" => "0.12",
       "bch_available" => "0.00000000",
       "eurusd_fee" => "0.25",
       "ethusd_fee" => "0.25",
       "btc_available" => "0.00000000",
       "xrpeur_fee" => "0.25",
       "eur_balance" => "0.00",
       "btceur_fee" => "0.25",
       "usd_balance" => "0.00",
       "bch_balance" => "0.00000000",
       "xrpusd_fee" => "0.25",
       "ltcusd_fee" => "0.25",
       "eth_available" => "0.00000000",
       "bch_reserved" => "0.00000000",
       "ltceur_fee" => "0.25",
       "etheur_fee" => "0.25",
       "eur_reserved" => "0.00",
       "ethbtc_fee" => "0.25",
       "xrp_balance" => "0.00000000",
       "ltc_available" => "0.00000000",
       "bchbtc_fee" => "0.12",
       "eth_reserved" => "0.00000000",
       "btcusd_fee" => "0.25",
       "usd_available" => "0.00",
       "xrp_available" => "0.00000000",
       "usd_reserved" => "0.00",
       "btc_reserved" => "0.00000000"
      }}
  """
  @spec balance_all(Credentials.t() | nil) :: tuple()
  def balance_all(creds \\ nil), do: private("/v2/balance/", [], creds)

  @doc """
  Fetches user transaction data for all currencies.

  Example successful response:

      {:ok,
      [
       %{
         "btc" => 0.0,
         "datetime" => "2018-02-02 13:08:20",
         "eth" => "0.41245141",
         "eth_eur" => 725.54,
         "eur" => "-299.25",
         "fee" => "0.75",
         "id" => 51366122,
         "order_id" => 880205621,
         "type" => "2",
         "usd" => 0.0
       },
       %{
         "btc" => 0.0,
         "btc_usd" => "0.00",
         "datetime" => "2018-02-02 13:00:29",
         "eur" => "300.00",
         "fee" => "0.00",
         "id" => 51351200,
         "type" => "0",
         "usd" => 0.0
       },
       ....
      ]}

  """
  @spec user_transactions_all(Credentials.t() | nil) :: tuple()
  def user_transactions_all(creds \\ nil), do: private("/v2/user_transactions/", [], creds)

  @doc """
  Fetches user transaction data for a currency pair.

  Example successful response:

      {:ok,
      [
       %{
         "btc" => 0.0,
         "datetime" => "2018-02-02 13:08:20",
         "eth" => "0.41245141",
         "eth_eur" => 725.54,
         "eur" => "-299.25",
         "fee" => "0.75",
         "id" => 51366122,
         "order_id" => 880205621,
         "type" => "2",
         "usd" => 0.0
       },
       %{
         "btc" => 0.0,
         "btc_usd" => "0.00",
         "datetime" => "2018-02-02 13:00:29",
         "eur" => "300.00",
         "fee" => "0.00",
         "id" => 51351200,
         "type" => "0",
         "usd" => 0.0
       },
       ....
      ]}

  """
  @spec user_transactions(CurrencyPair.t(), Credentials.t() | nil) :: tuple()
  def user_transactions(%CurrencyPair{} = currency_pair, creds \\ nil),
    do: private("/v2/user_transactions/#{segment(currency_pair)}/", [], creds)

  @doc """
  Fetches open orders data for a currency pair.

  Example successful response:

      {:ok,
      [
       %{
         "amount" => "0.10000000",
         "datetime" => "2018-02-13 16:24:00",
         "id" => "951827494",
         "price" => "750.00",
         "type" => "1"
       }
      ]}
  """
  @spec open_orders(CurrencyPair.t(), Credentials.t() | nil) :: tuple()
  def open_orders(%CurrencyPair{} = currency_pair, creds \\ nil),
    do: private("/v2/open_orders/#{segment(currency_pair)}/", [], creds)

  @doc """
  Fetches open orders data for all currencies.

  Example successful response:

      {:ok,
      [
       %{
         "amount" => "0.10000000",
         "currency_pair" => "ETH/EUR",
         "datetime" => "2018-02-13 16:24:00",
         "id" => "951827494",
         "price" => "750.00",
         "type" => "1"
       }
      ]}
  """
  @spec open_orders_all(Credentials.t() | nil) :: tuple()
  def open_orders_all(creds \\ nil), do: private("/v2/open_orders/all/", [], creds)

  @doc """
  Fetches order status.

  Example successful response:

      {:ok, %{"status" => "Open", "transactions" => []}}
  """
  @spec order_status(String.t(), Credentials.t() | nil) :: tuple()
  def order_status(id, creds \\ nil), do: private("/order_status/", [id: id], creds)

  @doc """
  Cancels an order.

  Example successful response:

      {:ok, %{"amount" => 0.1, "id" => 951827494, "price" => 750.0, "type" => 1}}
  """
  @spec cancel_order(String.t(), Credentials.t() | nil) :: tuple()
  def cancel_order(id, creds \\ nil), do: private("/v2/cancel_order/", [id: id], creds)

  @doc """
  Cancels all orders.

  Example successful response:

      {:ok, true}
  """
  @spec cancel_all_orders(Credentials.t() | nil) :: tuple()
  def cancel_all_orders(creds \\ nil), do: private("/cancel_all_orders/", [], creds)

  @doc """
  Places a limit buy order for a currency pair.

  Accepts list of optional parameters as a keyword list. Allowed keys are: `limit_price` or `daily_order`.
  Only one of these can be present. See [Bitstamp API docs](https://www.bitstamp.net/api/#buy-order)
  for more info.

  Example successful response:


  """
  @spec buy(CurrencyPair.t(), float(), float(), list() | nil, Credentials.t() | nil) :: tuple()
  def buy(%CurrencyPair{} = currency_pair, amount, price, opts \\ [], creds \\ nil)
      when is_list(opts),
      do:
        private(
          "/v2/buy/#{segment(currency_pair)}/",
          opts ++ [amount: to_string(amount), price: to_string(price)],
          creds
        )

  @doc """
  Places a buy market order for a currency pair.
  """
  @spec buy_market(CurrencyPair.t(), float(), Credentials.t() | nil) :: tuple()
  def buy_market(%CurrencyPair{} = currency_pair, amount, creds \\ nil),
    do: private("/v2/buy/market/#{segment(currency_pair)}/", [amount: to_string(amount)], creds)

  @doc """
  Places a limit sell order for a currency pair.

  Accepts list of optional parameters as a keyword list. Allowed keys are: `limit_price` or `daily_order`.
  Only one of these can be present. See [Bitstamp API docs](https://www.bitstamp.net/api/#sell-order)
  for more info.
  """
  @spec sell(CurrencyPair.t(), float(), float(), list() | nil, Credentials.t() | nil) :: tuple()
  def sell(%CurrencyPair{} = currency_pair, amount, price, opts \\ [], creds \\ nil)
      when is_list(opts),
      do:
        private(
          "/v2/sell/#{segment(currency_pair)}/",
          opts ++ [amount: to_string(amount), price: to_string(price)],
          creds
        )

  @doc """
  Places a sell market order for a currency pair.
  """
  @spec sell_market(CurrencyPair.t(), float(), Credentials.t() | nil) :: tuple()
  def sell_market(%CurrencyPair{} = currency_pair, amount, creds \\ nil),
    do: private("/v2/sell/market/#{segment(currency_pair)}/", [amount: to_string(amount)], creds)

  @doc """
  Fetches all withdrawal requests.
  """
  @spec withdrawal_requests(list(), Credentials.t() | nil) :: tuple()
  def withdrawal_requests(opts \\ [], creds \\ nil) when is_list(opts),
    do: private("/v2/withdrawal-requests/", opts, creds)

  @doc """
  Executes bitcoin withdrawal.
  """
  @spec withdrawal_btc(float(), String.t(), boolean(), Credentials.t() | nil) :: tuple()
  def withdrawal_btc(amount, address, instant, creds \\ nil) do
    instant =
      case instant do
        true -> 1
        false -> 0
      end

    coin_withdrawal(creds, "bitcoin_withdrawal", amount, address, [instant: instant], :v1)
  end

  @doc """
  Executes litecoin withdrawal.
  """
  @spec withdrawal_ltc(float(), String.t(), Credentials.t() | nil) :: tuple()
  def withdrawal_ltc(amount, address, creds \\ nil),
    do: coin_withdrawal(creds, "ltc_withdrawal", amount, address)

  @doc """
  Executes ethereum withdrawal.
  """
  @spec withdrawal_eth(float(), String.t(), Credentials.t() | nil) :: tuple()
  def withdrawal_eth(amount, address, creds \\ nil),
    do: coin_withdrawal(creds, "eth_withdrawal", amount, address)

  @doc """
  Executes ripple withdrawal.
  """
  @spec withdrawal_xrp(float(), String.t(), String.t() | nil, Credentials.t() | nil) :: tuple()
  def withdrawal_xrp(amount, address, destination_tag \\ nil, creds \\ nil) do
    opts =
      case destination_tag do
        nil -> []
        tag -> [destination_tag: tag]
      end

    coin_withdrawal(creds, "xrp_withdrawal", amount, address, opts)
  end

  @doc """
  Executes bitcoin cash withdrawal.
  """
  @spec withdrawal_bch(float(), String.t(), Credentials.t() | nil) :: tuple()
  def withdrawal_bch(amount, address, creds \\ nil),
    do: coin_withdrawal(creds, "bch_withdrawal", amount, address)

  @doc """
  Executes ripple withdrawal using v1 API.
  """
  @spec withdrawal_ripple(float(), String.t(), String.t(), Credentials.t() | nil) :: tuple()
  def withdrawal_ripple(amount, address, currency, creds \\ nil),
    do: coin_withdrawal(creds, "ripple_withdrawal", amount, address, [currency: currency], :v1)

  defp coin_withdrawal(creds, endpoint, amount, address, opts \\ [], version \\ :v2),
    do:
      private(
        "/#{version(version)}#{endpoint}/",
        opts ++ [amount: to_string(amount), address: address],
        creds
      )

  @doc """
  Retrieves bitcoin deposit address.
  """
  @spec deposit_address_btc(Credentials.t() | nil) :: tuple()
  def deposit_address_btc(creds \\ nil),
    do: coin_deposit_address(creds, "bitcoin_deposit_address", :v1)

  @doc """
  Retrieves litecoin deposit address.
  """
  @spec deposit_address_ltc(Credentials.t() | nil) :: tuple()
  def deposit_address_ltc(creds \\ nil), do: coin_deposit_address(creds, "ltc_address")

  @doc """
  Retrieves ethereum deposit address.
  """
  @spec deposit_address_eth(Credentials.t() | nil) :: tuple()
  def deposit_address_eth(creds \\ nil), do: coin_deposit_address(creds, "eth_address")

  @doc """
  Retrieves xrp deposit address.
  """
  @spec deposit_address_xrp(Credentials.t() | nil) :: tuple()
  def deposit_address_xrp(creds \\ nil), do: coin_deposit_address(creds, "xrp_address")

  @doc """
  Retrieves bitcoin cash deposit address.
  """
  @spec deposit_address_bch(Credentials.t() | nil) :: tuple()
  def deposit_address_bch(creds \\ nil), do: coin_deposit_address(creds, "bch_address")

  @doc """
  Retrieves ripple deposit address using v1 API.
  """
  @spec deposit_address_ripple(Credentials.t() | nil) :: tuple()
  def deposit_address_ripple(creds \\ nil), do: coin_deposit_address(creds, "ripple_address", :v1)

  defp coin_deposit_address(creds, endpoint, version \\ :v2),
    do: private("/#{version(version)}#{endpoint}/", [], creds)

  @spec unconfirmed_btc(Credentials.t() | nil) :: tuple()
  def unconfirmed_btc(creds \\ nil), do: private("/unconfirmed_btc/", [], creds)

  @doc """
  Executes a transfer of funds from sub account to main account.
  """
  @spec transfer_to_main(float(), String.t(), any(), Credentials.t() | nil) :: tuple()
  def transfer_to_main(amount, currency, sub_account_id \\ nil, creds \\ nil) do
    opts =
      case sub_account_id do
        nil -> [amount: amount, currency: currency]
        sub_account_id -> [amount: to_string(amount), currency: currency, subAccount: sub_account_id]
      end

    private("/transfer-to-main/", opts, creds)
  end

  @doc """
  Executes a transfer of funds from main account to sub account.
  """
  @spec transfer_from_main(float(), String.t(), Credentials.t() | nil) :: tuple()
  def transfer_from_main(amount, currency, sub_account_id, creds \\ nil) do
    opts = [amount: to_string(amount), currency: currency, subAccount: sub_account_id]

    private("/transfer-from-main/", opts, creds)
  end

  @doc """
  Executes a bank withdrawal.
  """
  @spec open_bank_withdrawal(BankWithdrawal.t(), Credentials.t() | nil) :: tuple()
  def open_bank_withdrawal(%BankWithdrawal{} = bank_withdrawal, creds \\ nil),
    do: private("/v2/withdrawal/open/", Map.to_list(bank_withdrawal), creds)

  @doc """
  Retrieves bank withdrawal status.
  """
  @spec bank_withdrawal_status(String.t(), Credentials.t() | nil) :: tuple()
  def bank_withdrawal_status(id, creds \\ nil),
    do: private("/v2/withdrawal/status/", [id: id], creds)

  @doc """
  Cancels bank withdrawal status.
  """
  @spec cancel_bank_withdrawal(String.t(), Credentials.t() | nil) :: tuple()
  def cancel_bank_withdrawal(id, creds \\ nil),
    do: private("/v2/withdrawal/cancel/", [id: id], creds)

  @doc """
  Creates new liquidation address.
  """
  @spec new_liquidation_address(String.t(), Credentials.t() | nil) :: tuple()
  def new_liquidation_address(liquidation_currency, creds \\ nil) do
    opts = [liquidation_currency: liquidation_currency]

    private("/v2/liquidation_address/new/", opts, creds)
  end

  @doc """
  Retireves transactions for liquidation address.
  """
  @spec liquidation_address_info(String.t() | nil, Credentials.t() | nil) :: tuple()
  def liquidation_address_info(address \\ nil, creds \\ nil) do
    opts =
      case address do
        nil -> []
        address -> [address: address]
      end

    private("/v2/liquidation_address/info/", opts, creds)
  end

  defp public(uri, data \\ []) do
    case ApiClient.get(uri, [], data) do
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

  defp private(uri, data, creds) do
    creds =
      case creds do
        creds = %Credentials{} ->
          creds

        _ ->
          %Credentials{
            key: Application.get_env(:ex_bitstamp, :creds).key,
            secret: Application.get_env(:ex_bitstamp, :creds).secret,
            customer_id: Application.get_env(:ex_bitstamp, :creds).customer_id
          }
      end

    case ApiClient.post(uri, {:form, data ++ signature(creds)}) do
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

  defp segment(%CurrencyPair{from: from, to: to}), do: String.downcase(from <> to)
end
