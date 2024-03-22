// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC4626 {
    function decimals() external view returns (uint8);
    function asset() external view returns (address assetTokenAddress);
    function convertToShares(uint256 assets) external view returns (uint256 shares);
    function convertToAssets(uint256 shares) external view returns (uint256 assets);
}
