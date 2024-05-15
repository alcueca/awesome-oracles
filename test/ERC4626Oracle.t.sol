// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// types
import { IERC20 } from "forge-std/interfaces/IERC20.sol";
import { IERC4626 } from "forge-std/interfaces/IERC4626.sol";
// libraries
import { console2 } from "forge-std/Test.sol";
// contracts
import { Test } from "forge-std/Test.sol";
import { ERC4626Oracle } from "../src/erc4626/ERC4626Oracle.sol";

contract ERC4626OracleTest is Test {
    // erc4626 oracles
    ERC4626Oracle yDaiOracle;
    ERC4626Oracle yUsdcOracle;
    ERC4626Oracle yWethOracle;

    // yearn v3 vaults
    address constant yDAI = 0x028eC7330ff87667b6dfb0D94b954c820195336c;
    address constant yUSDC = 0xBe53A109B494E5c9f97b9Cd39Fe969BE68BF6204;
    address constant yWETH = 0xc56413869c6CDf96496f2b1eF801fEDBdFA7dDB0;

    // underlying vault tokens
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    // prices at block 19537700
    uint256 constant DAI_yDAI = 999_573_011_923_275_867; // DAI/yDAI
    uint256 constant USDC_yUSDC = 999_918_000_000_000_000; // USDC/yUSDC
    uint256 constant WETH_yWETH = 999_987_596_242_017_279; // WETH/yWETH

    uint256 constant yDAI_DAI = 1_000_427_170_473_423_012; // yDAI/DAI
    uint256 constant yUSDC_USDC = 1_000_081_000_000_000_000; // yUSDC/USDC
    uint256 constant yWETH_WETH = 1_000_012_403_911_837_841; // yWETH/WETH

    function setUp() public {
        vm.createSelectFork("mainnet", block.number);
        yDaiOracle = new ERC4626Oracle(yDAI);
        yUsdcOracle = new ERC4626Oracle(yUSDC);
        yWethOracle = new ERC4626Oracle(yWETH);
    }

    function testUnderlyingAsset() public view {
        assertEq(address(yDaiOracle.ASSET()), DAI);
        assertEq(address(yUsdcOracle.ASSET()), USDC);
        assertEq(address(yWethOracle.ASSET()), WETH);
    }

    function testValueOfShares(uint256 daiAmt, uint256 usdcAmt, uint256 wethAmt) public view {
        // value of vault share tokens in terms of underlying tokens
        vm.assume(daiAmt <= IERC4626(yDAI).totalSupply());
        vm.assume(usdcAmt <= IERC4626(yUSDC).totalSupply());
        vm.assume(wethAmt <= IERC4626(yWETH).totalSupply());

        assertEq(yDaiOracle.valueOf(yDAI, DAI, daiAmt), IERC4626(yDAI).convertToAssets(daiAmt));
        assertEq(yUsdcOracle.valueOf(yUSDC, USDC, usdcAmt), IERC4626(yUSDC).convertToAssets(usdcAmt));
        assertEq(yWethOracle.valueOf(yWETH, WETH, wethAmt), IERC4626(yWETH).convertToAssets(wethAmt));
    }

    function testValueOfAssets(uint256 daiAmt, uint256 usdcAmt, uint256 wethAmt) public view {
        // value of underlying tokens in terms of vault share tokens
        vm.assume(daiAmt <= IERC4626(yDAI).totalAssets());
        vm.assume(usdcAmt <= IERC4626(yUSDC).totalAssets());
        vm.assume(wethAmt <= IERC4626(yWETH).totalAssets());

        assertEq(yDaiOracle.valueOf(DAI, yDAI, daiAmt), IERC4626(yDAI).convertToShares(daiAmt));
        assertEq(yUsdcOracle.valueOf(USDC, yUSDC, usdcAmt), IERC4626(yUSDC).convertToShares(usdcAmt));
        assertEq(yWethOracle.valueOf(WETH, yWETH, wethAmt), IERC4626(yWETH).convertToShares(wethAmt));
    }
}
