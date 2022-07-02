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

    constructor(){
        _mint(address(2),(1000 * 10 ** 18));

    }
}

contract ThirdToken is ERC20("UniversalValueToken","UVT",18) {

    constructor(){
        _mint(address(2),(1000 * 10 ** 18));

    }
}
contract RegistryTest is Test {
    
        WETH wETH;
        ThirdToken strongAndStable;
        DAOToken DT;

        UniswapV2Factory Factory;
        UniswapV2Router Router;
        Registry R;

        address owner;
        address defaultForge = address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);

    function setUp() public {

        vm.startPrank(address(2));
        wETH = new WETH();
        strongAndStable = new ThirdToken();
        DT = new DAOToken();
        
        Factory = new UniswapV2Factory(address(2));
        Factory.setFeeTo(address(2));
        Router = new UniswapV2Router(address(Factory), address(wETH));

        R = new Registry();
        owner = address(2);
        vm.stopPrank();

        // assertFalse(address(DT) == ttt); 
    }

    function testCannotUniinitialized() public {
        /// tests functions revert due to global uniinitialized state 
        vm.expectRevert(bytes("PausedOrUninitialized"));
        // vm.prank(address(3));
        // R.selfRegister(address(DT));
        // vm.expectRevert(bytes("PausedOrUninitialized"));
        vm.prank(address(4));
        R.calculateInitValue();
    }

    function testCannotInitialize(uint256 _reliableAmt, uint256 _a0zAmount) public {
        vm.assume(_reliableAmt > 0);
        vm.assume(_a0zAmount > 0);

        /// tests initialize function fails if sender not owner
        vm.expectRevert(bytes("UNAUTHORIZED"));
        vm.prank(address(9));
        R.setExternalPoints(address(Router), address(Factory), address(strongAndStable), 100, _reliableAmt, _a0zAmount);
        /// 0
        vm.startPrank(owner);
        vm.expectRevert(bytes("zero val given"));
        R.setExternalPoints(address(Router), address(Factory), address(strongAndStable), 0, _reliableAmt, _a0zAmount);
        vm.expectRevert(bytes("zero val given"));
        R.setExternalPoints(address(Router), address(0), address(strongAndStable), 32, _reliableAmt, _a0zAmount);
        vm.expectRevert(bytes("zero val given"));
        R.setExternalPoints(address(Router), address(Factory), address(0), 32, _reliableAmt, _a0zAmount);
        vm.expectRevert(bytes("zero val given"));
        R.setExternalPoints(address(0), address(Factory), address(strongAndStable), 32, _reliableAmt, _a0zAmount);
        vm.stopPrank();
        /// tests initialize function fails if sender not owner
        vm.expectRevert(bytes("UNAUTHORIZED"));
        vm.startPrank(address(9));
        R.setExternalPoints(address(Router), address(Factory), address(strongAndStable), 100, _reliableAmt, _a0zAmount);
    }

    function testInitialize() public {

        /// test can initialize via setExternalPoints
        uint256 SS5 = strongAndStable.balanceOf(owner);
        uint256 AZ5 = 200 * 10 ** 18;
        console.log("SS5 ", SS5, " AZ5 ", AZ5);

        
        assertTrue(SS5>0);
        assertTrue(AZ5>0);
        // vm.startPrank(address(5));
        // IERC20(address(strongAndStable)).transfer(owner, SS5);
        // IERC20(address(R)).transfer(owner, AZ5);
        // vm.stopPrank();
        vm.prank(owner);
        strongAndStable.approve(address(R), type(uint256).max-1);

        vm.prank(owner);
        address p = R.setExternalPoints(address(Router), address(Factory), address(strongAndStable), 100, SS5, AZ5 );
        IUniswapV2Pair pool = IUniswapV2Pair(p);

        assertFalse(address(pool) == address(0), "failed on pool address is 0");
        assertFalse(pool.token0() == address(0), "failed on token address is 0");

        vm.stopPrank();
        vm.prank(address(1337));
        /// it can pass isInit() modifier 
        vm.expectRevert(bytes("UniswapV2Library: INSUFFICIENT_LIQUIDITY"));
        R.calculateInitValue();
        assertTrue( R.balanceOf(address(5)) > 1000, "zero balance");
        assertTrue( IERC20(pool.token0()).balanceOf(address(5)) > 1_000_000_000 );
        assertTrue( IERC20(pool.token1()).balanceOf(address(5)) > 1_000_000_000 );

        vm.startPrank(address(5));
        IERC20(pool.token0()).approve(p, type(uint256).max);
        IERC20(pool.token1()).approve(p, type(uint256).max);

        //assertTrue(R.calculateInitValue() > 0, "failed to calculate init value");
    }

    function testCannotPausedWhenUninit(address _any) public {
        vm.assume(_any != address(0));
        vm.expectRevert(bytes("is default 0"));
        vm.prank(owner);
        R.setParentAuthPoolToZero(_any);
    }

    function testCannotRecreateSameFactory() public {}

    function testCannotsetParentAuthPoolToZero() public {}
    

    
}
