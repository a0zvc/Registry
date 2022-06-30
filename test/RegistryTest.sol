// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

import "solmate/tokens/WETH.sol";
import "solmate/tokens/ERC20.sol";
import "uniswapv2-solc0.8/interfaces/IERC20.sol";
import "uniswapv2-solc0.8/UniswapV2Router.sol";
import "uniswapv2-solc0.8/UniswapV2Factory.sol";
import "uniswapv2-solc0.8/interfaces/IUniswapV2Pair.sol";


import "../src/Registry.sol";

contract DAOToken is ERC20("CommunityValueToken","CVT",18) {
    address public thisIsMyAddress;
    constructor(){
        _mint(address(5),(1000 * 10 ** 18));
        thisIsMyAddress = address(this);
    }
}

contract thirdToken is ERC20("UniversalValueToken","UVT",18) {
    address public thisIsMyAddress; 
    constructor(){
        _mint(address(5),(1000 * 10 ** 18));
        thisIsMyAddress = address(this);
    }
}
contract RegistryTest is Test {
    
        WETH wETH;
        thirdToken tT= new thirdToken();
        IERC20 strongAndStable = IERC20(address(tT));
        UniswapV2Factory Factory;
        UniswapV2Router Router;

        Registry R;
        address owner;
        DAOToken DT = new DAOToken();
        address defaultForge = address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);

    function setUp() public {
        wETH = new WETH();
        Factory = new UniswapV2Factory(address(this));
        Router = new UniswapV2Router(address(Factory), address(wETH));

        vm.prank(address(2));
        R = new Registry();
        owner = address(2);
    }

    function testCannotUniinitialized() public {
        /// tests functions revert due to global uniinitialized state 
        vm.expectRevert(bytes("PausedOrUninitialized"));
        vm.prank(address(3));
        R.selfRegister(address(DT));
        vm.expectRevert(bytes("PausedOrUninitialized"));
        vm.prank(address(4));
        R.calculateInitValue();
    }

    function testCannotInitialize() public {
        /// tests initialize function fails if sender not owner
        vm.expectRevert(bytes("UNAUTHORIZED"));
        vm.prank(address(9));
        R.setExternalPoints(address(Router), address(Factory), address(strongAndStable), 100);
        /// 0
        vm.startPrank(owner);
        vm.expectRevert(bytes("zero val given"));
        R.setExternalPoints(address(Router), address(Factory), address(strongAndStable), 0);
        vm.expectRevert(bytes("zero val given"));
        R.setExternalPoints(address(Router), address(0), address(strongAndStable), 32);
        vm.expectRevert(bytes("zero val given"));
        R.setExternalPoints(address(Router), address(Factory), address(0), 32);
        vm.expectRevert(bytes("zero val given"));
        R.setExternalPoints(address(0), address(Factory), address(strongAndStable), 32);
        vm.stopPrank();
        /// tests initialize function fails if sender not owner
        vm.expectRevert(bytes("UNAUTHORIZED"));
        vm.startPrank(address(9));
        R.setExternalPoints(address(Router), address(Factory), address(strongAndStable), 100);
    }

    function testInitialize() public {
        /// test can initialize via setExternalPoints
        vm.prank(owner);
        IUniswapV2Pair pool = IUniswapV2Pair( R.setExternalPoints(address(Router), address(Factory), address(strongAndStable), 100));
        assertTrue(address(pool) != address(0), "failed on pool address is 0");
        assertTrue(pool.token0() != address(0), "failed on token address is 0");

        /// can calulate initValue if it can pass isInit() modifier

    }

    function testCannotRecreateSameFactory() public {
        /// tests that the identical base pair cannot be reinitialized
        //R.setExternalPoints(address(Router), address(Factory), address(DT), 100);

    }

    function testCannotsetParentAuthPoolToZero() public {}


}
