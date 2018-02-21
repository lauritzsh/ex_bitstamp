defmodule ExBitstamp.BankWithdrawal do
  @moduledoc """
  Provides a struct for bank withdrawal parameters.
  """

  alias __MODULE__

  @type t :: %BankWithdrawal{
          amount: float(),
          account_currency: String.t(),
          name: String.t(),
          iban: String.t(),
          bic: String.t(),
          address: String.t(),
          postal_code: String.t(),
          city: String.t(),
          country: String.t(),
          type: String.t(),
          bank_name: String.t(),
          bank_address: String.t(),
          bank_postal_code: String.t(),
          bank_city: String.t(),
          bank_country: String.t(),
          currency: String.t(),
          comment: String.t()
        }

  @enforce_keys [
    :amount,
    :account_currency,
    :name,
    :iban,
    :bic,
    :address,
    :postal_code,
    :city,
    :country,
    :type
  ]
  defstruct [
    :amount,
    :account_currency,
    :name,
    :iban,
    :bic,
    :address,
    :postal_code,
    :city,
    :country,
    :type,
    :bank_name,
    :bank_address,
    :bank_postal_code,
    :bank_city,
    :bank_country,
    :currency,
    :comment
  ]
end
