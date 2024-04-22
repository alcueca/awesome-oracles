# Oracle Aggregator

The Oracle Aggregator is a series of immutable smart contracts that provide data feeds from existing smart contracts
with a consistent interface and behaviour.

## Specification

https://github.com/alcueca/oracles/blob/main/spec/spec.md

## Deployments

## Design Principles

- Follow the spec
- Standardized disclaimer with limits of each feed
- Immutable contracts
- Multiple overlapping oracles
- Composition of IOracles

## Contributing

Please do. Open a PR.

## Security Considerations

These contracts are unaudited. Please consider having them reviewed before integrating. Each contract includes a
disclaimer with safe limits for operation. Please make sure they fit your use case.

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
