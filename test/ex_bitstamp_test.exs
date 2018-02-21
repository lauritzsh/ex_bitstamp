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
      post: fn url, data ->
        ApiClientMock.post(url, data, Poison.encode!(expected_response))
      end do
      assert {:ok, results} = test_fn.()
      assert results = expected_response
    end
  end
end
