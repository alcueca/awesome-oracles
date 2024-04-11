// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

interface IWSTETH {
    /**
     * @notice Get address of stETH contract
     */
    function stETH() external view returns (address);
}
