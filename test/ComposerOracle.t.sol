// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// types
import { IOracle } from "../src/interfaces/IOracle.sol";
import { IERC20 } from "forge-std/interfaces/IERC20.sol";
// libraries
import { console2 } from "forge-std/Test.sol";
// contracts
import { Test } from "forge-std/Test.sol";
import { ComposerOracle } from "../src/composer/ComposerOracle.sol";
import { MockOracle } from "./MockOracle.sol";

contract ComposerOracleTest is Test {
    // composer oracle
    ComposerOracle composerOracle;

    // mock chainlink oracle
    MockOracle chainlinkOracle;

    // token constants
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    // raw chainlink prices at about block 19639105
    uint256 constant DAI_WETH = 284_796_189_987_735;
    uint256 constant WETH_DAI = 3_511_282_928_479_716_769_792;
    uint256 constant USDC_WETH = 284_240_453_521_380;
    uint256 constant WETH_USDC = 3_518_148_059;

    ComposerOracle.SetOracle[] setOracles;
    ComposerOracle.SetPath[] setPaths;
    address[] wethPath;
    address[] roundtripPath;

    function setUp() public {
        vm.createSelectFork("mainnet", block.number);
        chainlinkOracle = new MockOracle();
        chainlinkOracle.setPair(DAI, 18, WETH, 18, DAI_WETH);
        chainlinkOracle.setPair(WETH, 18, DAI, 18, WETH_DAI);
        chainlinkOracle.setPair(USDC, 6, WETH, 18, USDC_WETH);
        chainlinkOracle.setPair(WETH, 18, USDC, 6, WETH_USDC);
        wethPath.push(WETH);

        roundtripPath.push(WETH);
        roundtripPath.push(USDC);
        roundtripPath.push(WETH);

        setOracles.push(ComposerOracle.SetOracle({ base: DAI, quote: WETH, oracle: chainlinkOracle }));
        setOracles.push(ComposerOracle.SetOracle({ base: WETH, quote: DAI, oracle: chainlinkOracle }));
        setOracles.push(ComposerOracle.SetOracle({ base: USDC, quote: WETH, oracle: chainlinkOracle }));
        setOracles.push(ComposerOracle.SetOracle({ base: WETH, quote: USDC, oracle: chainlinkOracle }));

        setPaths.push(ComposerOracle.SetPath({ base: DAI, quote: USDC, path: wethPath }));
        setPaths.push(ComposerOracle.SetPath({ base: USDC, quote: DAI, path: wethPath }));
        setPaths.push(ComposerOracle.SetPath({ base: DAI, quote: DAI, path: roundtripPath }));

        composerOracle = new ComposerOracle(setOracles, setPaths);
    }

    function testMockOracles() public view {
        // price of one DAI whole unit, in terms of ETH
        assertEq(chainlinkOracle.getQuote(1e18, DAI, WETH), DAI_WETH);
        // price of one WETH whole unit, in terms of DAI
        assertEq(chainlinkOracle.getQuote(1e18, WETH, DAI), WETH_DAI);
        // price of one USDC whole unit, in terms of ETH
        assertEq(chainlinkOracle.getQuote(1e6, USDC, WETH), USDC_WETH);
        // price of one WETH whole unit, in terms of USDC
        assertEq(chainlinkOracle.getQuote(1e18, WETH, USDC), WETH_USDC);
    }

    function testComposerOracleOracles() public view {
        // The oracle for DAI/WETH is chainlink
        assertEq(address(composerOracle.oracles(DAI, WETH)), address(chainlinkOracle));
        // The oracle for WETH/DAI is chainlink
        assertEq(address(composerOracle.oracles(WETH, DAI)), address(chainlinkOracle));
        // The oracle for USDC/WETH is chainlink
        assertEq(address(composerOracle.oracles(USDC, WETH)), address(chainlinkOracle));
        // The oracle for WETH/USDC is chainlink
        assertEq(address(composerOracle.oracles(WETH, USDC)), address(chainlinkOracle));
    }

    function testDirectValueOfOneUnit() public view {
        // price of one DAI whole unit, in terms of ETH
        assertEq(composerOracle.getQuote(1e18, DAI, WETH), DAI_WETH);
        // price of one WETH whole unit, in terms of DAI
        assertEq(composerOracle.getQuote(1e18, WETH, DAI), WETH_DAI);
        // price of one USDC whole unit, in terms of ETH
        assertEq(composerOracle.getQuote(1e6, USDC, WETH), USDC_WETH);
        // price of one WETH whole unit, in terms of USDC
        assertEq(composerOracle.getQuote(1e18, WETH, USDC), WETH_USDC);
    }

    function testFuzzDirectValueOf(uint64 amount) public view {
        // price of one DAI whole unit, in terms of ETH
        assertEq(composerOracle.getQuote(amount, DAI, WETH), amount * DAI_WETH / 1e18);
        // price of one WETH whole unit, in terms of DAI
        assertEq(composerOracle.getQuote(amount, WETH, DAI), amount * WETH_DAI / 1e18);
        // price of one USDC whole unit, in terms of ETH
        assertEq(composerOracle.getQuote(amount, USDC, WETH), amount * USDC_WETH / 1e6);
        // price of one WETH whole unit, in terms of USDC
        assertEq(composerOracle.getQuote(amount, WETH, USDC), amount * WETH_USDC / 1e18);
    }

    function testPathValueOfOneUnit() public view {
        // price of one DAI whole unit, in terms of USDC
        assertEq(composerOracle.getQuote(1e18, DAI, USDC), DAI_WETH * WETH_USDC / 1e18);
        // price of one USDC whole unit, in terms of DAI
        assertEq(composerOracle.getQuote(1e6, USDC, DAI), USDC_WETH * WETH_DAI / 1e18);
    }

    function testFuzzPathValueOf(uint64 amount) public view {
        // price of one DAI whole unit, in terms of USDC
        assertEq(composerOracle.getQuote(amount, DAI, USDC), (((amount * DAI_WETH) / 1e18) * WETH_USDC) / 1e18);
        // price of one USDC whole unit, in terms of DAI
        assertEq(composerOracle.getQuote(amount, USDC, DAI), (((amount * USDC_WETH) / 1e6) * WETH_DAI) / 1e18);
    }

    function testRoundtripValueOfOneUnit() public view {
        // price of one DAI whole unit, in terms of DAI, using multiple steps
        assertEq(composerOracle.getQuote(1e18, DAI, DAI), 999_999_837_147_677_368);
        // Value obtained experimentally, and explained by the loss of precision in the intermediate steps
    }
}
