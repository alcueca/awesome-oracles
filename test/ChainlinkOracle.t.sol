// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// types
import { IERC20 } from "forge-std/interfaces/IERC20.sol";
// libraries
import { console2 } from "forge-std/Test.sol";
// contracts
import { Test } from "forge-std/Test.sol";
import { ChainlinkOracle } from "../src/chainlink/ChainlinkOracle.sol";
import { Denominations } from "../src/lib/Denominations.sol";

contract ChainlinkOracleTest is Test {
    // erc4626 oracles
    ChainlinkOracle ethUsdOracle;
    ChainlinkOracle usdcEthOracle;

    address constant USDC_ETH_FEED = 0x986b5E1e1755e3C2440e960477f25201B0a8bbD4;
    address constant ETH_USD_FEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public {
        vm.createSelectFork("mainnet", 19702000);
        ethUsdOracle = new ChainlinkOracle(ETH_USD_FEED, WETH, Denominations.USD, 24 hours);
        usdcEthOracle = new ChainlinkOracle(USDC_ETH_FEED, USDC, WETH, 24 hours);
    }

    function testFeed() public view {
        assertEq(address(ethUsdOracle.FEED()), ETH_USD_FEED);
    }

    function testNumeratorAsset() public view {
        assertEq(ethUsdOracle.NUMERATOR_ASSET(), WETH);
    }

    function testDenominatorAsset() public view {
        assertEq(ethUsdOracle.DENOMINATOR_ASSET(), Denominations.USD);
    }

    function testMaxStaleness() public view {
        assertEq(ethUsdOracle.MAX_STALENESS(), 24 hours);
    }

    function testValueOfForward() public view {
        assertApproxEqRel(usdcEthOracle.valueOf(USDC, WETH, 3200e6), 1e18, 0.05e18);
        assertApproxEqRel(ethUsdOracle.valueOf(WETH, Denominations.USD, 2e18), 6400e18, 0.05e18);
    }

    function testValueOfReverse() public view {
        assertApproxEqRel(usdcEthOracle.valueOf(WETH, USDC, 2e18), 6400e18, 0.05e18);
        assertApproxEqRel(ethUsdOracle.valueOf(Denominations.USD, WETH, 3200e18), 1e18, 0.05e18);
    }
}
