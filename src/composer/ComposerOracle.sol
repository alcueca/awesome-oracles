// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { IOracle } from "../interfaces/IOracle.sol";

/**
 * @title ComposerOracle
 */
contract ComposerOracle is IOracle {
    event OracleSet(address indexed base, address indexed quote, IOracle indexed oracle);
    event PathSet(address indexed base, address indexed quote, address[] indexed path);

    struct OracleWithDecimals {
        IOracle oracle;
        uint8 baseDecimals;
        uint8 quoteDecimals;
    } // Decimals are needed to calculate priceOf

    struct SetOracle {
        address base;
        address quote;
        OracleWithDecimals oracleWithDecimals;
    }

    struct SetPath {
        address base;
        address quote;
        address[] path;
    }

    mapping(address base => mapping(address quote => OracleWithDecimals oracle)) public oracles;
    mapping(address base => mapping(address quote => address[] path)) public paths;

    constructor(SetOracle[] memory oracles_, SetPath[] memory paths_) {
        _setOracles(oracles_);
        _setPaths(paths_);
    }

    /// @notice Set or reset an array of oracle sources with decimals
    /// @param setOracles_ Array of SetOracle structs
    function _setOracles(SetOracle[] memory setOracles_) internal {
        uint256 oraclesToSet = setOracles_.length;
        unchecked {
            for (uint256 p; p < oraclesToSet; ++p) {
                SetOracle memory setOracle_ = setOracles_[p];
                oracles[setOracle_.base][setOracle_.quote] = setOracle_.oracleWithDecimals;
                emit OracleSet(setOracle_.base, setOracle_.quote, setOracle_.oracleWithDecimals.oracle);
            }
        }
    }

    /// @notice Set or reset an array of oracle paths
    /// @param setPaths_ Array of SetPath structs
    function _setPaths(SetPath[] memory setPaths_) internal {
        uint256 pathsToSet = setPaths_.length;

        unchecked {
            for (uint256 s; s < pathsToSet; ++s) {
                SetPath memory setPath_ = setPaths_[s];

                // Check that oracles for all intermediate pairs exist
                address[] memory path = setPath_.path;
                address base_ = setPath_.base;

                uint256 pathLength = path.length;
                for (uint256 p; p < pathLength; ++p) {
                    OracleWithDecimals memory oracle_ = oracles[base_][path[p]];
                    if (oracle_.oracle == IOracle(address(0))) revert OracleUnsupportedPair(base_, path[p]);
                    base_ = path[p];
                }

                paths[setPath_.base][setPath_.quote] = setPath_.path;
                emit PathSet(setPath_.base, setPath_.quote, setPath_.path);
            }
        }
    }

    /// @notice Convert amountBase base into quote at the latest oracle price, through a path is exists.
    /// @param base base token
    /// @param quote quote token
    /// @param amountBase Amount of base to convert to quote
    /// @return amountQuote Amount of quote token converted from base
    function valueOf(address base, address quote, uint256 amountBase)
        external
        view
        virtual
        override
        returns (uint256 amountQuote)
    {
        amountQuote = _valueOfPath(base, quote, amountBase);
    }

    /// @notice Return the price of base in quote terms, with 18 decimals, at the latest oracle price, through a path is
    /// exists.
    /// @param base base token
    /// @param quote quote token
    /// @return price price of base in quote terms, with 18 decimals
    function priceOf(address base, address quote) external view virtual override returns (uint256 price) {
        OracleWithDecimals memory oracle = oracles[base][quote];
        if (address(oracle.oracle) == address(0)) {
            // No direct oracle, check path
            address[] memory path = paths[base][quote];
            if (path.length == 0) revert OracleUnsupportedPair(base, quote);
            oracle = oracles[base][path[0]];
        }
        uint256 baseUnit = 10 ** oracle.baseDecimals;

        price = _valueOfPath(base, quote, baseUnit) * 1e18 / 10 ** oracle.quoteDecimals;
    }

    /// @notice Convert amountBase base into quote, through a path is exists.
    /// @param base base token
    /// @param quote quote token
    /// @param amountBase Amount of base to convert to quote
    /// @return amountQuote Amount of quote token converted from base
    function _valueOfPath(address base, address quote, uint256 amountBase)
        internal
        view
        virtual
        returns (uint256 amountQuote)
    {
        amountQuote = amountBase;
        address[] memory path = paths[base][quote];
        uint256 pathLength = path.length;
        unchecked {
            for (uint256 p; p < pathLength; ++p) {
                amountQuote = _valueOfStep(base, path[p], amountQuote);
                base = path[p];
            }
        }
        amountQuote = _valueOfStep(base, quote, amountQuote);
    }

    /// @notice Convert amountBase base into quote for a direct oracle call.
    /// @param base base token
    /// @param quote quote token
    /// @param amountBase Amount of base to convert to quote
    /// @return amountQuote Amount of quote token converted from base
    function _valueOfStep(address base, address quote, uint256 amountBase)
        internal
        view
        returns (uint256 amountQuote)
    {
        OracleWithDecimals memory oracle = oracles[base][quote];
        if (address(oracle.oracle) == address(0)) revert OracleUnsupportedPair(base, quote);
        amountQuote = oracle.oracle.valueOf(base, quote, amountBase);
    }
}
