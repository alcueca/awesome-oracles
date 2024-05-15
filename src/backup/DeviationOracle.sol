// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { IOracle } from "../interfaces/IOracle.sol";

/**
 * @title ComposerOracle
 * @notice This Oracle takes a primary and a secondary IOracles as sources. If the values from both oracles differ by
 * less or are equal to `maxDeviation`, the result from the primary oracle is used. Otherwise, the result from the
 * secondary oracle is used. It is suggested that the primary is an oracle that is updated frequently (and therefore
 * more accurate), but easy to manipulate, and the secondary is an oracle that is updated less frequently but harder
 * to manipulate. An example would be to use Uniswap or other DEX as primary, and Chainlink as secondary.
 */
contract DeviationOracle is IOracle {
    IOracle public primary;
    IOracle public secondary;
    uint256 public maxDeviation; // 10^18. 5*10^16 is 5%

    constructor(IOracle primary_, IOracle secondary_, uint256 maxDeviation_) {
        primary = primary_;
        secondary = secondary_;
        maxDeviation = maxDeviation_;
    }

    /// @notice Convert amountBase base into quote. Use the primary oracle if the difference between the primary and
    /// secondary oracles is less than or equal to `maxDeviation`, otherwise use the secondary oracle.
    /// @param base base token
    /// @param quote quote token
    /// @param amountBase Amount of base to convert to quote
    /// @return amountQuote Amount of quote token converted from base
    function valueOf(address base, address quote, uint256 amountBase)
        external
        view
        virtual
        override
        returns (uint256)
    {
        uint256 primaryQuote = primary.valueOf(base, quote, amountBase);
        uint256 secondaryQuote = secondary.valueOf(base, quote, amountBase);
        if (
            primaryQuote * (1e18 - maxDeviation) >= secondaryQuote
                && primaryQuote * (1e18 + maxDeviation) <= secondaryQuote
        ) {
            return primaryQuote;
        } else {
            return secondaryQuote;
        }
    }

    // solhint-disable-next-line no-empty-blocks
    function priceOf(address base, address quote) external view override returns (uint256) {
        // Deprecated
    }
}
