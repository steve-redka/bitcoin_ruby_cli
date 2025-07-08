# BitcoinRubyCli

Toy command line utility for having a bitcoin wallet. Supports one (1) address.

The private key for it is stored in `wallet.key` file. 

## System Requirements

- Ruby (>= 3.2 recommended)
- [libsecp256k1 ](https://github.com/bitcoin-core/secp256k1/) library.

## Installing

```bash
git clone git@github.com:steve-redka/bitcoin_ruby_cli.git
cd bitcoin_ruby_cli
bundle
bin/bitcoin_ruby_cli create
```

### With docker

```
docker compose build

docker compose run app ruby bin/bitcoin_ruby_cli create
docker compose run app ruby bin/bitcoin_ruby_cli balance
docker compose run app ruby bin/bitcoin_ruby_cli send <address> <amount_in_sats or btc>
```

## Usage

```bash
ruby bin/bitcoin_ruby_cli create|balance|send
```
## Running tests

```
bundle exec rspec
```