// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BytesLib} from "./BytesLib.sol";
import {ChainlinkOracle} from "./ChainlinkOracle.sol";
import {AggregatorV3Interface} from "./AggregatorV3Interface.sol";

/// @title Chainlink Path Library
/// @author 0xSplits
/// @notice Utilities for converting Chainlink Feed paths to and from bytes
library ChainlinkPath {
    /// -----------------------------------------------------------------------
    /// libraries
    /// -----------------------------------------------------------------------

    using BytesLib for bytes;

    /// -----------------------------------------------------------------------
    /// constants
    /// -----------------------------------------------------------------------

    /// @dev size of one packed encoded feed (20 Bytes Feed + 3 Bytes StaleAfter + 1 Byte Decimals + 1 Byte Mul)
    uint24 private constant PATH_UNIT_SIZE = 25;

    /// -----------------------------------------------------------------------
    /// functions
    /// -----------------------------------------------------------------------

    /// @notice get the number of feeds in the path
    function len(bytes memory path) internal pure returns (uint256) {
        return path.len(PATH_UNIT_SIZE);
    }

    /// @notice get feeds from a path (packed encoded bytes)
    function getFeeds(bytes memory path) internal pure returns (ChainlinkOracle.Feed[] memory feeds) {
        uint256 length = len(path);
        feeds = new ChainlinkOracle.Feed[](length);
        for (uint256 i; i < length;) {
            feeds[i] = getFeed(path, i);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice get a single feed from a path at a given index
    function getFeed(bytes memory path, uint256 index) internal pure returns (ChainlinkOracle.Feed memory feed) {
        uint256 offset = index * PATH_UNIT_SIZE;
        feed.feed = AggregatorV3Interface(path.toAddress(offset));
        feed.staleAfter = path.toUint24(offset + 20);
        feed.decimals = path.toUint8(offset + 23);
        feed.mul = path.toBool(offset + 24);
    }

    /// @notice get a path (packed encoded bytes) from feeds
    function getPath(ChainlinkOracle.Feed[] memory feeds) internal pure returns (bytes memory path) {
        uint256 length = feeds.length;
        for (uint256 i; i < length;) {
            path = bytes.concat(
                path, abi.encodePacked(feeds[i].feed, feeds[i].staleAfter, feeds[i].decimals, feeds[i].mul)
            );
            unchecked {
                ++i;
            }
        }
    }
}
