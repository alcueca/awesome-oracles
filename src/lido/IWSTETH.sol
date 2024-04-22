// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "forge-std/interfaces/IERC20.sol";

interface IWSTETH is IERC20 {
    /**
     * @notice Get address of stETH contract
     */
    function stETH() external view returns (address);

    /**
     * @notice Get amount of wstETH obtained for a given amount of stETH
     * @param _stETHAmount amount of stETH
     * @return Amount of wstETH obtained for a given stETH amount
     */
    function getWstETHByStETH(uint256 _stETHAmount) external view returns (uint256);

    /**
     * @notice Get amount of stETH obtained for a given amount of wstETH
     * @param _wstETHAmount amount of wstETH
     * @return Amount of stETH obtained for a given wstETH amount
     */
    function getStETHByWstETH(uint256 _wstETHAmount) external view returns (uint256);
}
