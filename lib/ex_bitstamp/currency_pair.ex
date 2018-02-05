defmodule ExBitstamp.CurrencyPair do
  alias __MODULE__

  @enforce_keys [:from, :to]
  defstruct [:from, :to]

  def btcusd() do
    %CurrencyPair{from: "BTC", to: "USD"}
  end

  def btceur() do
    %CurrencyPair{from: "BTC", to: "EUR"}
  end

  def eurusd() do
    %CurrencyPair{from: "EUR", to: "USD"}
  end

  def xrpusd() do
    %CurrencyPair{from: "XRP", to: "USD"}
  end

  def xrpeur() do
    %CurrencyPair{from: "XRP", to: "EUR"}
  end

  def xrpbtc() do
    %CurrencyPair{from: "XRP", to: "BTC"}
  end

  def ltcusd() do
    %CurrencyPair{from: "LTC", to: "USD"}
  end

  def ltceur() do
    %CurrencyPair{from: "LTC", to: "EUR"}
  end

  def ltcbtc() do
    %CurrencyPair{from: "LTC", to: "BTC"}
  end

  def ethusd() do
    %CurrencyPair{from: "ETH", to: "USD"}
  end

  def etheur() do
    %CurrencyPair{from: "ETH", to: "EUR"}
  end

  def ethbtc() do
    %CurrencyPair{from: "ETH", to: "BTC"}
  end

  def bchusd() do
    %CurrencyPair{from: "BCH", to: "USD"}
  end

  def bcheur() do
    %CurrencyPair{from: "BCH", to: "EUR"}
  end

  def bchbtc() do
    %CurrencyPair{from: "BCH", to: "BTC"}
  end
end
