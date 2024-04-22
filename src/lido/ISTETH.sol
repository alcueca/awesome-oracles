// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "forge-std/interfaces/IERC20.sol";

interface ISTETH is IERC20 {
    /**
     * @return the amount of shares that corresponds to `_ethAmount` protocol-controlled Ether.
     */
    function getSharesByPooledEth(uint256 _ethAmount) external view returns (uint256);

    /**
     * @return the amount of Ether that corresponds to `_sharesAmount` token shares.
     */
    function getPooledEthByShares(uint256 _sharesAmount) external view returns (uint256);
}
