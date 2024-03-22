// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC4626} from "./IERC4626.sol";

contract ERC4626Oracle {
    error OracleUnsupportedPair();

    IERC4626 public immutable VAULT;
    IERC20 public immutable ASSET;

    constructor(address _vault) {
        VAULT = IERC4626(_vault);
        ASSET = IERC20(VAULT.asset());
    }

    function valueOf(address base, address quote, uint256 baseAmount) external view returns (uint256 quoteAmount) {
        if (quote == address(VAULT) && base == address(ASSET)) {
            return VAULT.convertToShares(baseAmount);
        } else if (quote == address(ASSET) && base == address(VAULT)) {
            return VAULT.convertToAssets(baseAmount);
        } else {
            revert OracleUnsupportedPair();
        }
    }

    function priceOf(address base, address quote) external view returns (uint256 baseQuotePrice) {
        if (quote == address(VAULT) && base == address(ASSET)) {
            return VAULT.convertToShares(10 ** IERC20(ASSET).decimals());
        } else if (quote == address(ASSET) && base == address(VAULT)) {
            return VAULT.convertToAssets(10 ** VAULT.decimals());
        } else {
            revert OracleUnsupportedPair();
        }
    }
}
