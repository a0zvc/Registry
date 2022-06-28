// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

import "solmate/tokens/WETH.sol";
import "solmate/tokens/ERC20.sol";
import "uniswapv2-solc0.8/interfaces/IERC20.sol";
import "uniswapv2-solc0.8/UniswapV2Router.sol";
import "uniswapv2-solc0.8/UniswapV2Factory.sol";

import "../src/Registry.sol";

contract DAOToken is ERC20("CommunityValueToken","CVT",18) {
    constructor(){
        _mint(address(5),(1000 * 10 ** 18));
    }
}
contract thirdToken is ERC20("UniversalValueToken","UVT",18) {
    constructor(){
        _mint(address(5),(1000 * 10 ** 18));
    }
}
contract RegistryTest is Test {
    
        WETH wETH;
        UniswapV2Factory Factory;
        UniswapV2Router Router;

        Registry R;
        address ownerO;
        DAOToken DT = new DAOToken();

    function setUp() public {
        wETH = new WETH();
        Factory = new UniswapV2Factory(address(this));
        Router = new UniswapV2Router(address(Factory), address(wETH));

        R = new Registry(address(2));
        ownerO = address(2);
    }

    function testREVERTSUnititialized() public {
        vm.expectRevert(bytes("PausedOrUninitialized"));
        /// undescript address
        vm.prank(address(3));
        R.selfRegister(address(DT));
        vm.expectRevert(bytes("PausedOrUninitialized"));
        vm.prank(address(4));
        R.calculateInitValue();

    }


}
