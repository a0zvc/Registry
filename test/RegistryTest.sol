// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

import "solmate/tokens/WETH.sol";
import "uniswapv2-solc0.8/interfaces/IERC20.sol";
import "uniswapv2-solc0.8/UniswapV2Router.sol";
import "uniswapv2-solc0.8/UniswapV2Factory.sol";


contract RegistryTest is Test {

    function setUp() public {
        WETH wETH = new WETH();
        UniswapV2Factory Factory = new UniswapV2Factory(address(this));
        UniswapV2Router Router = new UniswapV2Router(address(Factory), address(wETH));
    }

    function testExample() public {
        assertTrue(true);
    }

    function testSetOwner() public {
        assertEq(address(0), address(0));
    }
}
