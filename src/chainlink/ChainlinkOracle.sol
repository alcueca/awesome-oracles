// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "./AggregatorV3Interface.sol";
import {ChainlinkPath} from "./ChainlinkPath.sol";
import {IOracle} from "../interfaces/IOracle.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

/// @title Chainlink Oracle
/// @notice forked from https://github.com/0xSplits/splits-oracle/blob/main/src/chainlink/oracle/ChainlinkOracleImpl.sol
/// @dev This contract uses token = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) to refer to ETH.
contract ChainlinkOracle is IOracle {
    /// -----------------------------------------------------------------------
    /// libraries
    /// -----------------------------------------------------------------------

    using FixedPointMathLib for uint256;
    using ChainlinkPath for bytes;

    /// -----------------------------------------------------------------------
    /// errors
    /// -----------------------------------------------------------------------

    error InvalidFeed_Decimals();

    /// -----------------------------------------------------------------------
    /// structs
    /// -----------------------------------------------------------------------

    struct SetPairDetailParams {
        address base;
        address quote;
        PairDetail pairDetail;
    }

    struct PairDetail {
        /// @notice packed encoded feed[]
        bytes path;
        /// @notice if true, the price calculated by the path will be inverted
        bool inverted;
    }

    struct Feed {
        AggregatorV3Interface feed;
        uint24 staleAfter;
        /// @dev decimals should be same as feed.decimals()
        uint8 decimals;
        /// @dev operation to perform on the price with the previous price in the path
        bool mul;
    }

    /// -----------------------------------------------------------------------
    /// storage - constants & immutables
    /// -----------------------------------------------------------------------

    uint256 internal constant WAD = 1e18;

    /// -----------------------------------------------------------------------
    /// storage - mutables
    /// -----------------------------------------------------------------------

    /// @notice The pair details
    mapping(address => mapping(address => PairDetail)) internal pairDetails;

    /// -----------------------------------------------------------------------
    /// constructor & initializer
    /// -----------------------------------------------------------------------

    /**
     * @notice constructor
     * @param _params Pair config to fetch price from chainlink feeds
     */
    constructor(SetPairDetailParams[] memory _params) {
        _set(_params);
    }

    /// -----------------------------------------------------------------------
    /// functions
    /// -----------------------------------------------------------------------

    /// -----------------------------------------------------------------------
    /// functions - public & external - view
    /// -----------------------------------------------------------------------

    /// @inheritdoc IOracle
    function valueOf(address base, address quote, uint256 baseAmount) external view returns (uint256 quoteAmount) {
        quoteAmount = _valueOf(base, quote, baseAmount);
    }

    /// @inheritdoc IOracle
    function priceOf(address base, address quote) external view returns (uint256 price) {
        price = _valueOf(base, quote, 10 ** IERC20(base).decimals());
    }

    /// -----------------------------------------------------------------------
    /// functions - private & internal - views
    /// -----------------------------------------------------------------------

    function _valueOf(address base, address quote, uint256 baseAmount) internal view returns (uint256) {
        // fetch pair details
        PairDetail memory pd = pairDetails[base][quote];

        // if path is not set, base-quote is not supported
        if (pd.path.length == 0) {
            revert OracleUnsupportedPair(base, quote);
        }

        // decode feeds from the path
        Feed[] memory feeds = pd.path.getFeeds();
        uint256 feedLength = feeds.length;

        uint256 price;
        uint256 answer;
        bool isInvalid;

        // fetch price for the first feed
        (price, isInvalid) = _getFeedAnswer(feeds[0]);
        if (isInvalid) revert OracleUntrustedData(base, quote);

        for (uint256 i = 1; i < feedLength;) {
            (answer, isInvalid) = _getFeedAnswer(feeds[i]);

            if (isInvalid) revert OracleUntrustedData(base, quote);

            if (feeds[i].mul) {
                price = price.mulWadDown(answer);
            } else {
                price = price.divWadDown(answer);
            }
            unchecked {
                ++i;
            }
        }

        // inverse the final price if path is inverted
        if (pd.inverted) price = WAD.divWadDown(price);

        if (price == 0) revert OracleUntrustedData(base, quote);

        return _convertPriceToQuoteAmount(base, quote, baseAmount, price);
    }

    function _getFeedAnswer(Feed memory _feed) internal view returns (uint256 scaledAnswer, bool isInvalid) {
        (
            , /* uint80 roundId, */
            int256 answer,
            , /* uint256 startedAt, */
            uint256 updatedAt,
            /* uint80 answeredInRound */
        ) = _feed.feed.latestRoundData();

        // check for stale price
        if (updatedAt + _feed.staleAfter < block.timestamp) {
            isInvalid = true;
        }
        if (answer < 0) {
            isInvalid = true;
        }

        // scale answert to 18 decimals
        if (_feed.decimals <= 18) {
            return (uint256(answer) * 10 ** (18 - _feed.decimals), isInvalid);
        } else {
            return (uint256(answer) / 10 ** (_feed.decimals - 18), isInvalid);
        }
    }

    function _convertPriceToQuoteAmount(address base, address quote, uint256 baseAmount, uint256 price)
        internal
        view
        returns (uint256 finalAmount)
    {
        uint8 baseDecimals = IERC20(base).decimals();
        uint8 quoteDecimals = IERC20(quote).decimals();

        finalAmount = price * baseAmount;
        if (18 > quoteDecimals) {
            finalAmount = finalAmount / (10 ** (18 - quoteDecimals));
        } else if (18 < quoteDecimals) {
            finalAmount = finalAmount * (10 ** (quoteDecimals - 18));
        }
        finalAmount = finalAmount / 10 ** baseDecimals;
    }

    function _set(SetPairDetailParams[] memory params_) internal {
        uint256 length = params_.length;
        for (uint256 i; i < length;) {
            _validate(params_[i]);
            _set(params_[i]);
            unchecked {
                ++i;
            }
        }
    }

    function _set(SetPairDetailParams memory params_) internal {
        PairDetail memory pairDetail = params_.pairDetail;
        pairDetails[params_.base][params_.quote] = pairDetail;
        pairDetail.inverted = !pairDetail.inverted;
        pairDetails[params_.quote][params_.base] = pairDetail;
    }

    function _validate(SetPairDetailParams memory params_) private view {
        Feed[] memory feed = params_.pairDetail.path.getFeeds();

        uint256 length = feed.length;
        for (uint256 i; i < length;) {
            if (feed[i].feed.decimals() != feed[i].decimals) revert InvalidFeed_Decimals();
            unchecked {
                ++i;
            }
        }
    }
}
