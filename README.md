# Awesome Oracles

Despite their critical role in DeFi, oracles are often poorly understood by developers and users. The goal of Awesome
Oracles is to rectify that.

1. [Oracles](#erc-7226-oracles): Example [ERC-7726](https://ethereum-magicians.org/t/erc-7726-common-quote-oracle/20351)
   integrations of popular oracles. More about the standard in the [specification](./spec/spec.md) and the accompanying
   [discussion thread](https://ethereum-magicians.org/t/erc-7726-common-quote-oracle/20351).

1. [Resources](#resources): A curated collection of high-signal educational resources about blockchain oracles.

## ERC-7226 Oracles

### Design Principles

- Follow the spec
- Standardized disclaimer with limits of each feed
- Immutable contracts
- Multiple overlapping oracles
- Composition of IOracles

### Contributing

Please do. Open a PR. Some things that are always welcome:
 - Add content to this README
 - Fixes to existing oracle adapters
 - Better descriptions on when the existing oracle adapters can be trusted
 - Audits for existing oracle adapters
 - Deployment addresses for ERC-7726 oracle adapters
 - New ERC-7726 oracle adapters

Please remember to run the following two commands before pushing to conform to our coding style.

```
yarn prettier:write
forge fmt
```

### Security Considerations

These contracts are unaudited. Please consider having them reviewed before integrating. Each contract includes a
disclaimer with safe limits for operation. Please make sure they fit your use case.

## Other Compatible Oracles

Check [euler-price-oracle](https://github.com/euler-xyz/euler-price-oracle) for more compatible oracles.

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

## Resources

- [Oracle Risk and Security Standards: An Introduction (Pt. 1)](https://chaoslabs.xyz/posts/oracle-risk-and-security-standards-an-introduction)
- [Oracle Risk and Security Standards: Network Architectures and Topologies (Pt. 2)](https://chaoslabs.xyz/posts/oracle-risk-and-security-standards-network-architectures-and-topologies-pt-2)
- [Oracle Risk and Security Standards: Price Composition Methodologies (Pt. 3)](https://chaoslabs.xyz/posts/oracle-price-composition-methodologies)
- [Euler Price Oracles Whitepaper](https://github.com/euler-xyz/euler-price-oracle/blob/master/docs/whitepaper.md)
- [Oracle Risk Assessment: RedStone](https://hackmd.io/@PrismaRisk/RedStone)
- [The oracle conundrum](https://www.liquity.org/blog/the-oracle-conundrum)
- [Alternative Prisma Oracles Comparative Analysis](https://hackmd.io/@PrismaRisk/AlternativeOracles)
- [Getting Prices Right](https://hackernoon.com/getting-prices-right)
