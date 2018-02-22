defmodule ExBitstampTest do
  use ExUnit.Case
  doctest ExBitstamp
  import Mock

  alias ExBitstamp.CurrencyPair

  test "fetches ticker data" do
    test_public_api(fn -> ExBitstamp.ticker(CurrencyPair.btcusd()) end)
  end

  test "fetches hourly ticker data" do
    test_public_api(fn -> ExBitstamp.ticker_hour(CurrencyPair.btcusd()) end)
  end

  test "fetches order book data" do
    test_public_api(fn -> ExBitstamp.order_book(CurrencyPair.btcusd()) end)
  end

  test "fetches transaction data" do
    test_public_api(fn -> ExBitstamp.transactions(CurrencyPair.btcusd(), time: "minute") end)
  end

  test "fetches trading pairs info data" do
    test_public_api(fn -> ExBitstamp.trading_pairs_info() end)
  end

  test "fetches eur/usd conversion data" do
    test_public_api(fn -> ExBitstamp.eur_usd() end)
  end

  test "fetches balance data for currency pair" do
    test_private_api(fn -> ExBitstamp.balance(CurrencyPair.btcusd()) end)
  end

  test "fetches all balance data" do
    test_private_api(fn -> ExBitstamp.balance_all() end)
  end

  test "fetches all user transactions" do
    test_private_api(fn -> ExBitstamp.user_transactions_all() end)
  end

  test "fetches user transactions for currency pair" do
    test_private_api(fn -> ExBitstamp.user_transactions(CurrencyPair.btcusd()) end)
  end

  test "fetches open orders for currency pair" do
    test_private_api(fn -> ExBitstamp.open_orders(CurrencyPair.btcusd()) end)
  end

  test "fetches all open orders" do
    test_private_api(fn -> ExBitstamp.open_orders_all() end)
  end

  test "fetches order status" do
    test_private_api(fn -> ExBitstamp.order_status(1) end)
  end

  test "cancels order" do
    test_private_api(fn -> ExBitstamp.cancel_order(1) end)
  end

  test "cancels all orders" do
    test_private_api(fn -> ExBitstamp.cancel_all_orders() end)
  end

  test "places limit buy order" do
    test_private_api(fn -> ExBitstamp.buy(CurrencyPair.btcusd(), 1.0, 10000.0) end)
  end

  test "places buy market order" do
    test_private_api(fn -> ExBitstamp.buy_market(CurrencyPair.btcusd(), 1.0) end)
  end

  test "places limit sell order" do
    test_private_api(fn -> ExBitstamp.sell(CurrencyPair.btcusd(), 1.0, 10000.0) end)
  end

  test "places sell market order" do
    test_private_api(fn -> ExBitstamp.sell_market(CurrencyPair.btcusd(), 1.0) end)
  end

  test "fetches withdrawal requests" do
    test_private_api(fn -> ExBitstamp.withdrawal_requests() end)
  end

  test "executes bitcoin withdrawal" do
    test_private_api(fn -> ExBitstamp.withdrawal_btc(1.0, "address", true) end)
  end

  test "executes litecoin withdrawal" do
    test_private_api(fn -> ExBitstamp.withdrawal_ltc(1.0, "address") end)
  end

  test "executes ethereum withdrawal" do
    test_private_api(fn -> ExBitstamp.withdrawal_eth(1.0, "address") end)
  end

  test "executes ripple withdrawal" do
    test_private_api(fn -> ExBitstamp.withdrawal_xrp(1.0, "address", "tag") end)
  end

  test "executes bitcoin cash withdrawal" do
    test_private_api(fn -> ExBitstamp.withdrawal_bch(1.0, "address") end)
  end

  test "executes v1 ripple withdrawal" do
    test_private_api(fn -> ExBitstamp.withdrawal_ripple(1.0, "address", "USD") end)
  end

  test "retrieves bitcoin deposit address" do
    test_private_api(fn -> ExBitstamp.deposit_address_btc() end)
  end

  test "retrieves litecoin deposit address" do
    test_private_api(fn -> ExBitstamp.deposit_address_ltc() end)
  end

  test "retrieves ethereum deposit address" do
    test_private_api(fn -> ExBitstamp.deposit_address_eth() end)
  end

  test "retrieves ripple deposit address" do
    test_private_api(fn -> ExBitstamp.deposit_address_xrp() end)
  end

  test "retrieves bitcoin cash deposit address" do
    test_private_api(fn -> ExBitstamp.deposit_address_bch() end)
  end

  test "retrieves v1 ripple deposit address" do
    test_private_api(fn -> ExBitstamp.deposit_address_ripple() end)
  end

  test "retrieves unconfirmed BTC data" do
    test_private_api(fn -> ExBitstamp.unconfirmed_btc() end)
  end

  test "transfers funds to main from sub account" do
    test_private_api(fn -> ExBitstamp.transfer_to_main(100.0, "USD", "subaccountid") end)
  end

  test "transfers funds from main to sub account" do
    test_private_api(fn -> ExBitstamp.transfer_from_main(100.0, "USD", "subaccountid") end)
  end

  test "executes bank withdrawal" do
    test_private_api(fn ->
      ExBitstamp.open_bank_withdrawal(%ExBitstamp.BankWithdrawal{
        amount: 1.0,
        account_currency: "USD",
        name: "Bank Name",
        iban: "IBAN",
        bic: "BIC",
        address: "Bank address",
        postal_code: "12345",
        city: "Bank City",
        country: "Bank Country",
        type: "sepa"
      })
    end)
  end

  test "retrieves bank withdrawal status" do
    test_private_api(fn -> ExBitstamp.bank_withdrawal_status("id") end)
  end

  test "cancels bank withdrawal" do
    test_private_api(fn -> ExBitstamp.cancel_bank_withdrawal("id") end)
  end

  test "creates new liquidation address" do
    test_private_api(fn -> ExBitstamp.new_liquidation_address("USD") end)
  end

  test "retrieves transactions for liquidation address" do
    test_private_api(fn -> ExBitstamp.liquidation_address_info("address") end)
  end

  defp test_public_api(test_fn, expected_response \\ %{"test_status" => "ok"}) do
    with_mock ExBitstamp.ApiClient,
      get: fn url, data, options ->
        ApiClientMock.get(url, data, options, Poison.encode!(expected_response))
      end do
      assert {:ok, results} = test_fn.()
      assert results = expected_response
    end
  end

  defp test_private_api(test_fn, expected_response \\ %{"test_status" => "ok"}) do
    with_mock ExBitstamp.ApiClient,
      post: fn url, {:form, data} ->
        assert data[:key] != nil
        assert data[:nonce] != nil
        assert data[:signature] != nil
        ApiClientMock.post(url, data, Poison.encode!(expected_response))
      end do
      assert {:ok, results} = test_fn.()
      assert results = expected_response
    end
  end
end
