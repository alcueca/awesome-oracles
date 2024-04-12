// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// types
import {IOracle} from "../src/interfaces/IOracle.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
// libraries
import {console2} from "forge-std/Test.sol";
// contracts
import {Test} from "forge-std/Test.sol";
import {ComposerOracle} from "../src/composer/ComposerOracle.sol";
import {MockOracle} from "./MockOracle.sol";

contract ComposerOracleTest is Test {
    // composer oracle
    ComposerOracle composerOracle;

    // mock chainlink oracle
    MockOracle chainlinkOracle;

    // token constants
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    // raw chainlink prices at block 19537700
    uint256 constant DAI_WETH = 284796189987735;
    uint256 constant WETH_DAI = 3511282928479716769792;
    uint256 constant USDC_WETH = 284240453521380;
    uint256 constant WETH_USDC = 3518148059;

    ComposerOracle.SetOracle[] setOracles;
    ComposerOracle.SetPath[] setPaths;
    address[] wethPath;

    function setUp() public {
        vm.createSelectFork("mainnet", block.number);
        chainlinkOracle = new MockOracle();
        chainlinkOracle.setPair(DAI, 18, WETH, 18, DAI_WETH);
        chainlinkOracle.setPair(WETH, 18, DAI, 18, WETH_DAI);
        chainlinkOracle.setPair(USDC, 6, WETH, 18, USDC_WETH);
        chainlinkOracle.setPair(WETH, 18, USDC, 6, WETH_USDC);
        wethPath.push(WETH);
        setOracles.push(ComposerOracle.SetOracle({
            base: DAI,
            quote: WETH,
            oracle: ComposerOracle.OracleWithDecimals({
                oracle: chainlinkOracle,
                baseDecimals: 18,
                quoteDecimals: 18
            })
        }));
        setOracles.push(ComposerOracle.SetOracle({
            base: WETH,
            quote: DAI,
            oracle: ComposerOracle.OracleWithDecimals({
                oracle: chainlinkOracle,
                baseDecimals: 18,
                quoteDecimals: 18
            })
        }));
        setOracles.push(ComposerOracle.SetOracle({
            base: USDC,
            quote: WETH,
            oracle: ComposerOracle.OracleWithDecimals({
                oracle: chainlinkOracle,
                baseDecimals: 6,
                quoteDecimals: 18
            })
        }));
        setOracles.push(ComposerOracle.SetOracle({
            base: WETH,
            quote: USDC,
            oracle: ComposerOracle.OracleWithDecimals({
                oracle: chainlinkOracle,
                baseDecimals: 18,
                quoteDecimals: 6
            })
        }));

        setPaths.push(ComposerOracle.SetPath({
            base: DAI,
            quote: USDC,
            path: wethPath
        }));
        setPaths.push(ComposerOracle.SetPath({
            base: USDC,
            quote: DAI,
            path: wethPath
        }));

        composerOracle = new ComposerOracle(setOracles, setPaths);
    }

//    function testOracleConfig() public view {
//        assertEq(address(lidoOracle.STETH()), STETH); // stETH config
//        assertEq(address(lidoOracle.WSTETH()), WSTETH); // wstETH config
//    }
//
//    function testScalarConfig() public view {
//        // should equal 10 ** asset decimals
//        assertEq(lidoOracle.WSTETH_SCALAR(), 10 ** IERC20(WSTETH).decimals());
//        assertEq(lidoOracle.STETH_SCALAR(), 10 ** IERC20(STETH).decimals());
//    }
//
//    function testPriceOf() public view {
//        // price of one stETH whole unit, in terms of wstETH
//        assertEq(lidoOracle.priceOf(STETH, WSTETH), STETH_WSTETH);
//
//        // price of one wstETH whole unit, in terms of stETH
//        assertEq(lidoOracle.priceOf(WSTETH, STETH), WSTETH_STETH);
//    }
//
//    function testValueOfStETH(uint256 stETHAmount) public view {
//        // value of given stETH amount, in terms of wstETH
//        vm.assume(stETHAmount <= IERC20(STETH).totalSupply());
//
//        assertEq(lidoOracle.valueOf(STETH, WSTETH, stETHAmount), IWSTETH(WSTETH).getWstETHByStETH(stETHAmount));
//    }
//
//    function testValueOfWstETH(uint256 wstETHAmount) public view {
//        // value of given wstETH amount, in terms of stETH
//        vm.assume(wstETHAmount <= IERC20(WSTETH).totalSupply());
//
//        assertEq(lidoOracle.valueOf(WSTETH, STETH, wstETHAmount), IWSTETH(WSTETH).getStETHByWstETH(wstETHAmount));
//    }
//
//    function testInvalidArgs(address base, address quote, uint256 amt) public {
//        // invalid input args revert with OracleUnsupported()
//        vm.assume(base != STETH || quote != WSTETH);
//        vm.assume(base != WSTETH || quote != STETH);
//
//        vm.expectRevert(abi.encodeWithSelector(IOracle.OracleUnsupportedPair.selector, base, quote));
//        lidoOracle.priceOf(base, quote);
//
//        vm.expectRevert(abi.encodeWithSelector(IOracle.OracleUnsupportedPair.selector, base, quote));
//        lidoOracle.valueOf(base, quote, amt);
//    }
}