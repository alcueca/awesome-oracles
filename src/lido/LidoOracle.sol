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

    /// @inheritdoc IOracle
    function getQuote(uint256 baseAmount, address base, address quote) external view returns (uint256 quoteAmount) {
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
