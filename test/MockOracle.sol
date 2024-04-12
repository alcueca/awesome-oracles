// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// types
import {IOracle} from "../src/interfaces/IOracle.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IERC4626} from "forge-std/interfaces/IERC4626.sol";
// libraries
import {BoringERC20} from "../src/libraries/BoringERC20.sol";

contract MockOracle is IOracle {
    struct Pair {
        uint256 ratio; // With 18 additional decimals
        uint8 baseDecimals;
        uint8 quoteDecimals;
    }

    mapping (address => mapping (address => Pair)) public pairs;

    function setPair(address base, uint8 baseDecimals, address quote, uint8 quoteDecimals, uint256 ratio) public {
        pairs[base][quote] = Pair({ ratio: ratio, baseDecimals: baseDecimals, quoteDecimals: quoteDecimals });
    }

    /// @notice Returns the value of baseAmount of baseAsset in quoteAsset terms.
    /// @param base The asset that the user needs to know the value for.
    /// @param quote The asset in which the user needs to value the `base`.
    /// @param baseAmount The amount of `base` that the user wants to know the value in `quote` for.
    /// @return quoteAmount The amount of `quote` that has the same value as `baseAmount`.
    function valueOf(address base, address quote, uint256 baseAmount) external view returns (uint256 quoteAmount) {
        Pair memory pair = pairs[base][quote];
        if (pair.ratio == 0) revert OracleUnsupportedPair(base, quote);
        return baseAmount * pair.ratio;
    }

    /// @notice Returns the price of baseAsset in quoteAsset terms.
    /// @param base The asset that the user needs to know the price for.
    /// @param quote The asset in which the user needs to price the `base`.
    /// @return baseQuotePrice The value of a minimum representable unit of `base` in `quote` terms, as an FP18.
    function priceOf(address base, address quote) external view returns (uint256 baseQuotePrice) {
        Pair memory pair = pairs[base][quote];
        if (pair.ratio == 0) revert OracleUnsupportedPair(base, quote);
        return 10 ** pair.baseDecimals * pair.ratio * 1e18 / 10 ** pair.quoteDecimals;
    }
}
