// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// types
import {IERC20} from "../src/interfaces/IERC20.sol";
// libraries
import {console2} from "forge-std/Test.sol";
// contracts
import {Test} from "forge-std/Test.sol";
import {ERC4626Oracle} from "../src/erc4626/ERC4626Oracle.sol";

contract ERC4626OracleTest is Test {
    // oracles
    ERC4626Oracle yVaultDAI;
    ERC4626Oracle yVaultUSDC;
    ERC4626Oracle yVaultWETH;

    // underlying vault tokens
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public {
        vm.createSelectFork("mainnet", block.number);
        yVaultDAI = new ERC4626Oracle(0x028eC7330ff87667b6dfb0D94b954c820195336c);
        yVaultUSDC = new ERC4626Oracle(0xBe53A109B494E5c9f97b9Cd39Fe969BE68BF6204);
        yVaultWETH = new ERC4626Oracle(0xc56413869c6CDf96496f2b1eF801fEDBdFA7dDB0);
    }

    function testUnderlyingAsset() public view {
        assertEq(address(yVaultDAI.ASSET()), DAI);
        assertEq(address(yVaultUSDC.ASSET()), USDC);
        assertEq(address(yVaultWETH.ASSET()), WETH);
    }

    function testAssetScalar() public view {
        // should be equal to the 10 ** underlying asset decimals
        assertEq(yVaultDAI.ASSET_SCALAR(), 10 ** IERC20(DAI).decimals());
        assertEq(yVaultUSDC.ASSET_SCALAR(), 10 ** IERC20(USDC).decimals());
        assertEq(yVaultWETH.ASSET_SCALAR(), 10 ** IERC20(WETH).decimals());
    }

    function testVaultScalar() public view {
        // yearn vault shares mirror decimals for the underlying token
        // dai and weth have 18 decimals, while usdc has 6 decimals
        assertEq(yVaultDAI.VAULT_SCALAR(), 1e18);
        assertEq(yVaultUSDC.VAULT_SCALAR(), 1e6);
        assertEq(yVaultWETH.VAULT_SCALAR(), 1e18);
    }
}
