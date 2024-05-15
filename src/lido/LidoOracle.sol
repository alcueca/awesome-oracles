// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// types
import { ISTETH } from "./ISTETH.sol";
import { IWSTETH } from "./IWSTETH.sol";
import { IOracle } from "../interfaces/IOracle.sol";
import { IERC20 } from "forge-std/interfaces/IERC20.sol";

contract LidoOracle is IOracle {
    ISTETH public immutable STETH;
    IWSTETH public immutable WSTETH;
    uint256 public immutable STETH_SCALAR;
    uint256 public immutable WSTETH_SCALAR;

    constructor(address wsteth_) {
        // configure wsteth constants
        WSTETH = IWSTETH(wsteth_);
        WSTETH_SCALAR = 10 ** IERC20(address(wsteth_)).decimals();

        // configure steth constants
        STETH = ISTETH(WSTETH.stETH());
        STETH_SCALAR = 10 ** STETH.decimals();
    }

    /// @notice Returns the value of baseAmount of baseAsset in quoteAsset terms.
    /// @param base The asset that the user needs to know the value for.
    /// @param quote The asset in which the user needs to value the `base`.
    /// @param baseAmount The amount of `base` that the user wants to know the value in `quote` for.
    /// @return quoteAmount The amount of `quote` that has the same value as `baseAmount`.
    function valueOf(address base, address quote, uint256 baseAmount) external view returns (uint256 quoteAmount) {
        if (base == address(STETH) && quote == address(WSTETH)) {
            // value of given stETH amount, in terms of wstETH
            return STETH.getSharesByPooledEth(baseAmount);
        } else if (base == address(WSTETH) && quote == address(STETH)) {
            // value of given wstETH amount, in terms of stETH
            return STETH.getPooledEthByShares(baseAmount);
        } else {
            // this oracle only supports pricing for stETH and wstETH asset pairs
            revert OracleUnsupportedPair(base, quote);
        }
    }

    /// @notice Returns the price of baseAsset in quoteAsset terms.
    /// @param base The asset that the user needs to know the price for.
    /// @param quote The asset in which the user needs to price the `base`.
    /// @return baseQuotePrice The value of a minimum representable unit of `base` in `quote` terms, as an FP18.
    function priceOf(address base, address quote) external view returns (uint256 baseQuotePrice) {
        if (base == address(STETH) && quote == address(WSTETH)) {
            // value of one stETH whole unit, in terms of wstETH
            return (STETH.getSharesByPooledEth(STETH_SCALAR) * 1e18) / WSTETH_SCALAR;
        } else if (base == address(WSTETH) && quote == address(STETH)) {
            // value of one wstETH whole unit, in terms of stETH
            return (STETH.getPooledEthByShares(WSTETH_SCALAR) * 1e18) / STETH_SCALAR;
        } else {
            // this oracle only supports pricing for stETH and wstETH asset pairs
            revert OracleUnsupportedPair(base, quote);
        }
    }
}
