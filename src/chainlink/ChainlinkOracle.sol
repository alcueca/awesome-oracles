// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// types
import { IERC20 } from "forge-std/interfaces/IERC20.sol";
import { AggregatorV3Interface } from "./AggregatorV3Interface.sol";
import { IOracle } from "../interfaces/IOracle.sol";
import { BoringERC20 } from "../libraries/BoringERC20.sol";

contract ChainlinkOracle is IOracle {
    using BoringERC20 for IERC20; // handles non-standard ERC20 tokens

    AggregatorV3Interface public immutable FEED;
    address public immutable NUMERATOR_ASSET;
    address public immutable DENOMINATOR_ASSET;
    uint256 public immutable MAX_STALENESS;

    uint256 internal immutable NUMERATOR_SCALAR;
    uint256 internal immutable DENOMINATOR_SCALAR;
    uint256 internal immutable FEED_SCALAR;

    constructor(address _feed, address _numeratorAsset, address _denominatorAsset, uint256 _maxStaleness) {
        FEED = AggregatorV3Interface(_feed);
        NUMERATOR_ASSET = _numeratorAsset;
        DENOMINATOR_ASSET = _denominatorAsset;
        MAX_STALENESS = _maxStaleness;

        NUMERATOR_SCALAR = 10 ** IERC20(_numeratorAsset).safeDecimals();
        DENOMINATOR_SCALAR = 10 ** IERC20(_denominatorAsset).safeDecimals();
        FEED_SCALAR = 10 ** AggregatorV3Interface(_feed).decimals(); // decimals is not optional for the aggregator
    }

    /// @inheritdoc IOracle
    function getQuote(uint256 baseAmount, address base, address quote) external view returns (uint256) {
        bool isForward = _getQueryDirection(base, quote);
        uint256 answer = _getAnswer(base, quote);

        if (isForward) {
            return (baseAmount * answer * 1e18) / (NUMERATOR_SCALAR * FEED_SCALAR);
        } else {
            return (baseAmount * 1e18 * FEED_SCALAR) / (answer * DENOMINATOR_SCALAR);
        }
    }

    /// @notice Fetch the latest price from Chainlink.
    /// @param base The asset that the user needs to know the value for.
    /// @param quote The asset in which the user needs to value the base.
    /// @dev Reverts if answer is non-positive or price is too stale.
    /// @return The latest Chainlink price.
    function _getAnswer(address base, address quote) internal view returns (uint256) {
        (, int256 answer,, uint256 updatedAt,) = FEED.latestRoundData();
        if (answer <= 0) {
            revert OracleUntrustedData(base, quote);
        }

        if (block.timestamp - updatedAt > MAX_STALENESS) {
            revert OracleUntrustedData(base, quote);
        }

        return uint256(answer);
    }

    /// @notice Get the direction of a price query.
    /// @param base The asset that the user needs to know the value for.
    /// @param quote The asset in which the user needs to value the base.
    /// @dev Reverts if base and quote do not correpsond to the feed assets.
    /// @return Whether if the query is in the direction of the feed.
    function _getQueryDirection(address base, address quote) internal view returns (bool /* isForward */ ) {
        if (base == NUMERATOR_ASSET && quote == DENOMINATOR_ASSET) {
            return true;
        } else if (base == DENOMINATOR_ASSET && quote == NUMERATOR_ASSET) {
            return false;
        } else {
            // this oracle supports a particular chainlink feed
            revert OracleUnsupportedPair(base, quote);
        }
    }
}
