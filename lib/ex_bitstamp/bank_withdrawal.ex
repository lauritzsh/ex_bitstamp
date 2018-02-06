defmodule ExBitstamp.BankWithdrawal do
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
