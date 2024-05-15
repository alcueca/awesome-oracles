// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// types
import { ISTETH } from "./ISTETH.sol";
import { IWSTETH } from "./IWSTETH.sol";
import { IOracle } from "../interfaces/IOracle.sol";

contract LidoOracle is IOracle {
    ISTETH public immutable STETH;
    IWSTETH public immutable WSTETH;

    constructor(address wsteth_) {
        // configure wsteth constants
        WSTETH = IWSTETH(wsteth_);

        // configure steth constants
        STETH = ISTETH(WSTETH.stETH());
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
}
