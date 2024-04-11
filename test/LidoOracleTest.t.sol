// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// types
import {ISTETH} from "../src/lido/ISTETH.sol";
import {IWSTETH} from "../src/lido/IWSTETH.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
// libraries
import {console2} from "forge-std/Test.sol";
// contracts
import {Test} from "forge-std/Test.sol";
import {LidoOracle} from "../src/lido/LidoOracle.sol";

contract LidoOracleTest is Test {
    // lido oracle
    LidoOracle lidoOracle;

    // token constants
    address constant STETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    address constant WSTETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;

    // prices at block 19537700
    uint256 constant STETH_WSTETH = 860734899407824565; // stETH/wstETH
    uint256 constant WSTETH_STETH = 1161797901639620023; // wstETH/stETH

    function setUp() public {
        vm.createSelectFork("mainnet", block.number);
        lidoOracle = new LidoOracle(WSTETH);
    }

    function testOracleConfig() public view {
        assertEq(address(lidoOracle.STETH()), STETH); // stETH config
        assertEq(address(lidoOracle.WSTETH()), WSTETH); // wstETH config
    }

    function testScalarConfig() public view {
        // should equal 10 ** asset decimals
        assertEq(lidoOracle.WSTETH_SCALAR(), 10 ** IERC20(WSTETH).decimals());
        assertEq(lidoOracle.STETH_SCALAR(), 10 ** IERC20(STETH).decimals());
    }

    function testPriceOf() public view {
        // price of one stETH whole unit, in terms of wstETH
        assertEq(lidoOracle.priceOf(STETH, WSTETH), STETH_WSTETH);

        // price of one wstETH whole unit, in terms of stETH
        assertEq(lidoOracle.priceOf(WSTETH, STETH), WSTETH_STETH);
    }

    function testValueOfStETH(uint256 stETHAmount) public view {
        // value of given stETH amount, in terms of wstETH
        vm.assume(stETHAmount <= IERC20(STETH).totalSupply());

        assertEq(lidoOracle.valueOf(STETH, WSTETH, stETHAmount), IWSTETH(WSTETH).getWstETHByStETH(stETHAmount));
    }

    function testValueOfWstETH(uint256 wstETHAmount) public view {
        // value of given wstETH amount, in terms of stETH
        vm.assume(wstETHAmount <= IERC20(WSTETH).totalSupply());

        assertEq(lidoOracle.valueOf(WSTETH, STETH, wstETHAmount), IWSTETH(WSTETH).getStETHByWstETH(wstETHAmount));
    }

    function testInvalidArgs(address base, address quote, uint256 amt) public {
        // invalid input args revert with OracleUnsupported()
        vm.assume(base != STETH || quote != WSTETH);
        vm.assume(base != WSTETH || quote != STETH);

        vm.expectRevert(abi.encodeWithSelector(LidoOracle.OracleUnsupportedPair.selector, base, quote));
        lidoOracle.priceOf(base, quote);

        vm.expectRevert(abi.encodeWithSelector(LidoOracle.OracleUnsupportedPair.selector, base, quote));
        lidoOracle.valueOf(base, quote, amt);
    }
}
