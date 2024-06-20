// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// types
import { IOracle } from "../interfaces/IOracle.sol";
import { IERC20 } from "forge-std/interfaces/IERC20.sol";
import { IERC4626 } from "forge-std/interfaces/IERC4626.sol";
// libraries
import { BoringERC20 } from "../libraries/BoringERC20.sol";

contract ERC4626Oracle is IOracle {
    using BoringERC20 for IERC20; // handles non-standard ERC20 tokens

    IERC4626 public immutable VAULT; // erc4626 vault

    IERC20 public immutable ASSET; // underlying vault token

    constructor(address _vault) {
        // configure erc4626 vault constants
        VAULT = IERC4626(_vault);

        // configure underlying vault token constants
        ASSET = IERC20(VAULT.asset());
    }

    /// @inheritdoc IOracle
    function getQuote(uint256 baseAmount, address base, address quote) external view returns (uint256 quoteAmount) {
        if (base == address(ASSET) && quote == address(VAULT)) {
            // value of given underlying asset tokens, in terms of vault shares
            return VAULT.convertToShares(baseAmount);
        } else if (base == address(VAULT) && quote == address(ASSET)) {
            // value of given underlying vault shares, in terms of the underlying token
            return VAULT.convertToAssets(baseAmount);
        } else {
            // this oracle supports a particular erc4626 vault, revert all other queries
            revert OracleUnsupportedPair(base, quote);
        }
    }
}
