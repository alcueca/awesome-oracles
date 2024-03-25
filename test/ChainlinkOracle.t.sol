// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ChainlinkOracle} from "../src/chainlink/ChainlinkOracle.sol";
import {AggregatorV3Interface} from "../src/chainlink/AggregatorV3Interface.sol";
import {ChainlinkPath} from "../src/chainlink/ChainlinkPath.sol";
import {Test} from "forge-std/Test.sol";

contract ChainlinkOracleTest is Test {
    ChainlinkOracle chainlinkOracle;

    using ChainlinkPath for ChainlinkOracle.Feed[];

    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    // prices at block 19493590
    uint256 constant DAI_USDC = 1_000796;
    uint256 constant DAI_WETH = 301188876850848;
    uint256 constant USDC_WETH = 301721419729073;

    uint256 constant USDC_DAI = 999204049119575887;
    uint256 constant WETH_DAI = 3320_175733100564835743;
    uint256 constant WETH_USDC = 3314_315572;

    address constant USDC_ETH_AGG = 0x986b5E1e1755e3C2440e960477f25201B0a8bbD4;
    address constant USDC_USD_AGG = 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6;
    address constant DAI_USD_AGG = 0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9;
    address constant ETH_USD_AGG = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    function setUp() public {
        vm.createSelectFork("mainnet", block.number);

        // setup feeds
        ChainlinkOracle.Feed memory USDC_ETH_FEED = ChainlinkOracle.Feed({
            feed: AggregatorV3Interface(USDC_ETH_AGG),
            staleAfter: 1 days,
            decimals: 18,
            mul: true
        });

        ChainlinkOracle.Feed memory DAI_USD_FEED =
            ChainlinkOracle.Feed({feed: AggregatorV3Interface(DAI_USD_AGG), staleAfter: 1 days, decimals: 8, mul: true});

        ChainlinkOracle.Feed memory ETH_USD_FEED_DIV = ChainlinkOracle.Feed({
            feed: AggregatorV3Interface(ETH_USD_AGG),
            staleAfter: 1 days,
            decimals: 8,
            mul: false
        });

        ChainlinkOracle.Feed memory USDC_USD_FEED_DIV = ChainlinkOracle.Feed({
            feed: AggregatorV3Interface(USDC_USD_AGG),
            staleAfter: 1 days,
            decimals: 8,
            mul: false
        });

        // set up paths for base-quotes
        ChainlinkOracle.Feed[] memory usdcETHPath = new ChainlinkOracle.Feed[](1);
        usdcETHPath[0] = USDC_ETH_FEED;

        ChainlinkOracle.Feed[] memory daiETHPath = new ChainlinkOracle.Feed[](2);
        daiETHPath[0] = DAI_USD_FEED;
        daiETHPath[1] = ETH_USD_FEED_DIV;

        ChainlinkOracle.Feed[] memory daiUSDCPath = new ChainlinkOracle.Feed[](2);
        daiUSDCPath[0] = DAI_USD_FEED;
        daiUSDCPath[1] = USDC_USD_FEED_DIV;

        // set up pair details for base-quote
        ChainlinkOracle.SetPairDetailParams[] memory setPairDetails = new ChainlinkOracle.SetPairDetailParams[](3);

        setPairDetails[0] = ChainlinkOracle.SetPairDetailParams({
            base: DAI,
            quote: USDC,
            pairDetail: ChainlinkOracle.PairDetail({path: daiUSDCPath.getPath(), inverted: false})
        });
        setPairDetails[1] = ChainlinkOracle.SetPairDetailParams({
            base: DAI,
            quote: WETH,
            pairDetail: ChainlinkOracle.PairDetail({path: daiETHPath.getPath(), inverted: false})
        });
        setPairDetails[2] = ChainlinkOracle.SetPairDetailParams({
            base: USDC,
            quote: WETH,
            pairDetail: ChainlinkOracle.PairDetail({path: usdcETHPath.getPath(), inverted: false})
        });

        // create new chainlink oracle
        chainlinkOracle = new ChainlinkOracle(setPairDetails);
    }

    function testPriceOf() public view {
        assertEq(chainlinkOracle.priceOf(WETH, USDC), WETH_USDC);
        assertEq(chainlinkOracle.priceOf(USDC, WETH), USDC_WETH);

        assertEq(chainlinkOracle.priceOf(WETH, DAI), WETH_DAI);
        assertEq(chainlinkOracle.priceOf(DAI, WETH), DAI_WETH);

        assertEq(chainlinkOracle.priceOf(USDC, DAI), USDC_DAI);
        assertEq(chainlinkOracle.priceOf(DAI, USDC), DAI_USDC);
    }

    function testValueOf(uint96 daiAmt, uint96 usdcAmt, uint96 wethAmt) public view {
        assertApproxEqAbs(chainlinkOracle.valueOf(WETH, USDC, wethAmt), calculateValueOf(WETH_USDC, wethAmt, 18), 1e7);
        assertApproxEqAbs(chainlinkOracle.valueOf(USDC, WETH, usdcAmt), calculateValueOf(USDC_WETH, usdcAmt, 6), 1e15);

        assertApproxEqAbs(chainlinkOracle.valueOf(DAI, USDC, daiAmt), calculateValueOf(DAI_USDC, daiAmt, 18), 1e7);
        assertApproxEqAbs(chainlinkOracle.valueOf(USDC, DAI, usdcAmt), calculateValueOf(USDC_DAI, usdcAmt, 6), 1e15);

        assertApproxEqAbs(chainlinkOracle.valueOf(WETH, DAI, wethAmt), calculateValueOf(WETH_DAI, wethAmt, 18), 1e15);
        assertApproxEqAbs(chainlinkOracle.valueOf(DAI, WETH, daiAmt), calculateValueOf(DAI_WETH, daiAmt, 18), 1e15);
    }

    function calculateValueOf(uint256 price, uint256 amountOfBase, uint256 decimalsOfBase)
        internal
        pure
        returns (uint256)
    {
        return price * (amountOfBase / 10 ** decimalsOfBase);
    }
}
