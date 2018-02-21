# ExBitstamp

Elixir client library for Bitstamp HTTP API.

## Installation

The package can be installed by adding `ex_bitstamp` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_bitstamp, "~> 0.1.0"}
  ]
end
```

## Usage

Bitstamp API requires valid API credentials for signature generation when hitting private endpoints. By default, `ExBitstamp` will look for credentials in your config file:

```elixir
config :ex_bitstamp,
  creds: %{
    customer_id: "customer_id",
    key: "key",
    secret: "secret"
  }
```

If you plan on using multiple API users and a single, default configuration doesn't work, you can pass a `ExBitstamp.Credentials` struct to all functions hitting private API as an optional, last argument:

```elixir
alias ExBitstamp.{Credentials, CurrencyPair}

creds = %Credentials{
  customer_id: "customer_id",
  key: "key",
  secret: "secret"
}

ExBitstamp.balance(CurrencyPair.btcusd(), creds)
```

For a complete list of functions you can refer to documentation which can be found at [https://hexdocs.pm/ex_bitstamp](https://hexdocs.pm/ex_bitstamp).

## Testing

``` bash
$ mix test
```

## Security

If you discover any security related issues, please email mvrkljan@gmail.com instead of using the issue tracker.

## Credits

- [Martin Vrkljan][link-author]
- [All Contributors][link-contributors]

## License

The MIT License (MIT). Please see [License File](LICENSE.md) for more information.

