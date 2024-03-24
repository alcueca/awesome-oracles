// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// types
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IERC4626} from "forge-std/interfaces/IERC4626.sol";
// libraries
import {BoringERC20} from "../libraries/BoringERC20.sol";

contract ERC4626Oracle {
    using BoringERC20 for IERC20; // handles non-standard ERC20 tokens

    error OracleUnsupportedPair();

    IERC4626 public immutable VAULT; // erc4626 vault
    uint256 public immutable VAULT_SCALAR; // 10 ** vault share token decimals

    IERC20 public immutable ASSET; // underlying vault token
    uint256 public immutable ASSET_SCALAR; // 10 ** underlying vault token decimals

    constructor(address _vault) {
        // configure erc4626 vault constants
        VAULT = IERC4626(_vault);
        VAULT_SCALAR = 10 ** IERC20(_vault).safeDecimals();

        // configure underlying vault token constants
        ASSET = IERC20(VAULT.asset());
        ASSET_SCALAR = 10 ** ASSET.safeDecimals();
    }

    /// @notice Returns the value of baseAmount of baseAsset in quoteAsset terms.
    /// @param base The asset that the user needs to know the value for.
    /// @param quote The asset in which the user needs to value the `base`.
    /// @param baseAmount The amount of `base` that the user wants to know the value in `quote` for.
    /// @return quoteAmount The amount of `quote` that has the same value as `baseAmount`.
    function valueOf(address base, address quote, uint256 baseAmount) external view returns (uint256 quoteAmount) {
        if (base == address(ASSET) && quote == address(VAULT)) {
            // value of given underlying asset tokens, in terms of vault shares
            return VAULT.convertToShares(baseAmount);
        } else if (base == address(VAULT) && quote == address(ASSET)) {
            // value of given underlying vault shares, in terms of the underlying token
            return VAULT.convertToAssets(baseAmount);
        } else {
            // this oracle supports a particular erc4626 vault, revert all other queries
            revert OracleUnsupportedPair();
        }
    }

    /// @notice Returns the price of baseAsset in quoteAsset terms.
    /// @param base The asset that the user needs to know the price for.
    /// @param quote The asset in which the user needs to price the `base`.
    /// @return baseQuotePrice The value of a minimum representable unit of `base` in `quote` terms, as an FP18.
    function priceOf(address base, address quote) external view returns (uint256 baseQuotePrice) {
        if (base == address(ASSET) && quote == address(VAULT)) {
            // value of one underlying asset whole unit, in terms of vault shares
            return (VAULT.convertToShares(ASSET_SCALAR) * 1e18) / VAULT_SCALAR;
        } else if (base == address(VAULT) && quote == address(ASSET)) {
            // value of one vault share whole unit, in terms of the underlying token
            return (VAULT.convertToAssets(VAULT_SCALAR) * 1e18) / ASSET_SCALAR;
        } else {
            // this oracle supports a particular erc4626 vault, revert all other queries
            revert OracleUnsupportedPair();
        }
    }
}
