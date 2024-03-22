// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "../interfaces/IERC20.sol";
import {IWSTETH} from "./IWSTETH.sol";
import {BoringERC20} from "../libraries/BoringERC20.sol";

contract LidoOracle {
    using BoringERC20 for IERC20;
    error OracleUnsupportedPair();

    IERC20 public immutable STETH;
    IWSTETH public immutable WSTETH;
    uint256 public immutable STETH_SCALAR;
    uint256 public immutable WSTETH_SCALAR;

    constructor(IWSTETH wsteth_) {
        IERC20 steth_ = IERC20(wsteth_.stETH());
        STETH = steth_;
        WSTETH = wsteth_;
        STETH_SCALAR = 10 ** steth_.safeDecimals();
        WSTETH_SCALAR = 10 ** IERC20(address(wsteth_)).safeDecimals();
    }

    /// @notice Returns the value of baseAmount of baseAsset in quoteAsset terms.
    /// @param base The asset that the user needs to know the value for.
    /// @param quote The asset in which the user needs to value the `base`.
    /// @param baseAmount The amount of `base` that the user wants to know the value in `quote` for.
    /// @return quoteAmount The amount of `quote` that has the same value as `baseAmount`.
    function valueOf(address base, address quote, uint256 baseAmount) external view returns (uint256 quoteAmount) {
        if (base == address(STETH) && quote == address(WSTETH)) {
            return WSTETH.getWstETHByStETH(baseAmount);
        } else if (base == address(WSTETH) && quote == address(STETH)) {
            return WSTETH.getStETHByWstETH(baseAmount);
        } else {
            revert OracleUnsupportedPair();
        }
    }

    /// @notice Returns the price of baseAsset in quoteAsset terms.
    /// @param base The asset that the user needs to know the price for.
    /// @param quote The asset in which the user needs to price the `base`.
    /// @return baseQuotePrice The value of a minimum representable unit of `base` in `quote` terms, as an FP18.
    function priceOf(address base, address quote) external view returns (uint256 baseQuotePrice) {
        if (base == address(STETH) && quote == address(WSTETH)) {
            return (WSTETH.getWstETHByStETH(STETH_SCALAR) * 1e18) / WSTETH_SCALAR;
        } else if (base == address(WSTETH) && quote == address(STETH)) {
            return (WSTETH.getStETHByWstETH(WSTETH_SCALAR) * 1e18) / STETH_SCALAR;
        } else {
            revert OracleUnsupportedPair();
        }
    }
}