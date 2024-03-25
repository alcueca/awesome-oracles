// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Conventional representation of non-ERC20 assets.
/// @dev For ETH, ERC-7535 will be applied, using `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE` as its address.
/// @dev For BTC, the address will be `0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB`.
/// @dev For national currencies and precious metals, the respective ISO 4217 code will be used.
library Denominations {
    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant BTC = 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB;
    address public constant USD = address(840);
}
