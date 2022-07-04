// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../src/Registry.sol";

import "uniswapv2-solc0.8/UniswapV2Router.sol";
import "uniswapv2-solc0.8/UniswapV2Factory.sol";
import "uniswapv2-solc0.8/interfaces/IUniswapV2Pair.sol";
// import "solmate/tokens/WETH.sol";

import "./mocks/WETH.sol";
import "./mocks/DAOt.sol";
import "./mocks/THIRDt.sol";


contract RegistryTest is Test {

    WETH wETH;

    DAOToken dao;
    ThirdToken third;

    IERC20 strongAndStable;
    IERC20 DT;

    UniswapV2Factory Factory;
    UniswapV2Router Router;
    Registry R;

    uint256 constant MAX_UINT = type(uint256).max;

    address owner;
    address defaultForge = address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);

    function setUp() public {

        wETH = new WETH();
        owner = address(2);

        vm.startPrank(owner);
        dao = new DAOToken();
        third = new ThirdToken();

        strongAndStable = IERC20(address(third));
        DT = IERC20(address(dao));

        Factory = new UniswapV2Factory(owner);
        Factory.setFeeTo(owner);
        Router = new UniswapV2Router(address(Factory), address(wETH));//fake weth

        R = new Registry();
        vm.stopPrank();
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
        // vm.assume(_shareEntry >= 2);//3?
        // vm.assume(_shareEntry <= 20000);
        /// test can initialize via setExternalPoints
        uint256 SS5 = strongAndStable.balanceOf(owner)/2;
        uint256 AZ5 = 200 * 10 ** 18;
        console.log("SS5 ", SS5, " AZ5 ", AZ5);

        assertTrue(SS5>0);
        assertTrue(AZ5>0);

        assertFalse(address(DT) == address(strongAndStable));

        vm.prank(owner);
        strongAndStable.approve(address(R), MAX_UINT);

        vm.prank(owner);
        address p = R.setExternalPoints(address(Router), address(Factory), address(strongAndStable), 222, SS5, AZ5 );
        IUniswapV2Pair pool = IUniswapV2Pair(p);

        assertFalse(address(pool) == address(0), "failed on pool address is 0");
        assertFalse(pool.token0() == address(0), "failed on token address is 0");
        vm.stopPrank();

        vm.prank(address(1337));
        /// it can pass isInit() modifier
        uint256 initValue = R.calculateInitValue();
        assertTrue(initValue > 0, "initValue is 0, failed");
        assertTrue(p == R.getParentPool(address(R)), "op pool address set and retrievable");
        address opTokenAddress = R.opTokenAddress();
        assertTrue(pool.token0() == opTokenAddress || pool.token1() == opTokenAddress, "opaddress not in mainpool");

        createDT_OP();
    }
    /// @dev @todo add fuzzing to liquidity nubers and pricing
    function createDT_OP() public {

        address pair = Factory.createPair(address(strongAndStable), address(DT));
        vm.startPrank(address(306));
        // DT.approve(pair, MAX_UINT);
        // strongAndStable.approve(pair, MAX_UINT);
        strongAndStable.approve(address(Router), MAX_UINT);
        DT.approve(address(Router), MAX_UINT);

        (,,uint256 l) = Router.addLiquidity(
            address(DT),
            address(strongAndStable),
            2000*10**18,
            9000*10**18,
            10_000,
            4_500,
            address(306),
            block.timestamp
        );
        vm.stopPrank();
        assertTrue(l>0,"failed add liqudity OP_DT");
    }


    function testCannotPausedWhenUninit(address _any) public {
        vm.assume(_any != address(0));
        vm.expectRevert(bytes("is default 0"));
        vm.prank(owner);
        R.setParentAuthPoolToZero(_any);
    }

    function testCannotRecreateSameFactory() public {

    }

    function testCannotsetParentAuthPoolToZero() public {

    }

    function testCreateDAOtOPpool() public {

    }



    function testCannotSelfRegister() public {
        testInitialize();
        vm.expectRevert(bytes("provided&OP lp pool:not found"));
        vm.startPrank(address(1337));
        R.selfRegister(address(DT));
        // vm.expectRevert(bytes("ERC20: insufficient allowance"));
        // R.selfRegister(address(DT));
        vm.stopPrank();
    }


    function testSelfRegister() public {
        vm.prank(address(1337));
        DT.approve(address(R), MAX_UINT);
        vm.prank(address(1337));
        strongAndStable.approve(address(R), MAX_UINT);
        testInitialize();
        
        vm.startPrank(address(1337));
        vm.expectRevert("provided&OP lp pool:not found");
        address pool = R.selfRegister(address(DT));

        // assertTrue(pool != address(0));
        // assertTrue(pool == R.getParentPool(address(DT)));
        // assertTrue(pool != R.getParentPool(address(R)));
    
        vm.stopPrank();
    }

}
