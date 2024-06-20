// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// types
import { IOracle } from "../src/interfaces/IOracle.sol";
import { IERC20 } from "forge-std/interfaces/IERC20.sol";
import { IERC4626 } from "forge-std/interfaces/IERC4626.sol";

contract MockOracle is IOracle {
    struct Pair {
        uint256 ratio; // One unit of base, in quote terms
        uint8 baseDecimals;
        uint8 quoteDecimals;
    }

    mapping(address => mapping(address => Pair)) public pairs;

    function setPair(address base, uint8 baseDecimals, address quote, uint8 quoteDecimals, uint256 ratio) public {
        pairs[base][quote] = Pair({ ratio: ratio, baseDecimals: baseDecimals, quoteDecimals: quoteDecimals });
    }

    /// @inheritdoc IOracle
    function getQuote(uint256 baseAmount, address base, address quote) external view returns (uint256 quoteAmount) {
        Pair memory pair = pairs[base][quote];
        if (pair.ratio == 0) revert OracleUnsupportedPair(base, quote);
        return baseAmount * pair.ratio / 10 ** pair.baseDecimals;
    }
}
