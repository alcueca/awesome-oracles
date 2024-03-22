// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC4626} from "./IERC4626.sol";

contract ERC4626Oracle {
    error OracleUnsupportedPair();

    IERC4626 public immutable VAULT;
    uint256 public immutable VAULT_SCALAR;

    IERC20 public immutable ASSET;
    uint256 public immutable ASSET_SCALAR;

    constructor(address _vault) {
        VAULT = IERC4626(_vault);
        VAULT_SCALAR = 10 ** VAULT.decimals();

        ASSET = IERC20(VAULT.asset());
        ASSET_SCALAR = 10 ** ASSET.decimals();
    }

    function valueOf(address base, address quote, uint256 baseAmount) external view returns (uint256 quoteAmount) {
        if (base == address(ASSET) && quote == address(VAULT)) {
            return VAULT.convertToShares(baseAmount);
        } else if (base == address(VAULT) && quote == address(ASSET)) {
            return VAULT.convertToAssets(baseAmount);
        } else {
            revert OracleUnsupportedPair();
        }
    }

    function priceOf(address base, address quote) external view returns (uint256 baseQuotePrice) {
        if (base == address(ASSET) && quote == address(VAULT)) {
            return (VAULT.convertToShares(ASSET_SCALAR) * 1e18) / VAULT_SCALAR;
        } else if (base == address(VAULT) && quote == address(ASSET)) {
            return (VAULT.convertToAssets(VAULT_SCALAR) * 1e18) / ASSET_SCALAR;
        } else {
            revert OracleUnsupportedPair();
        }
    }
}
