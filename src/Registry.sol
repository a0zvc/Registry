pragma solidity >=0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "solmate/auth/Owned.sol";

import "uniswapv2-solc0.8/interfaces/IUniswapV2Router.sol";
import "uniswapv2-solc0.8/interfaces/IUniswapV2Factory.sol";
import "uniswapv2-solc0.8/interfaces/IUniswapV2Pair.sol";

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./IRegistry.sol";

/// @title A0Z.VC Deal Registry
/// @author parseb (https://github.com/a0zvc/Registry/blob/main/src/Registry.sol)
/// @notice authonomous liqudity and venture bootstrapping protocol
/// @dev Experimental. Do not use.
/// @custom:security contact: petra306@protonmail.com

contract Registry is 
    ERC20("A0Z.VC", "A0Z"),
    Owned(msg.sender),
    IRegistry 
{   
    IERC20 opToken;
    IUniswapV2Router Router;
    IUniswapV2Factory Factory;

    uint256 constant MAX_UINT = type(uint256).max;

    mapping(address => address) parentAuthPool;

    /// @notice share of totalSupply used to determine value to be pladged
    uint256 public eligibilityShare;

    /// ######### Events #

    event selfRegistered(address indexed _parentToken, address indexed _pool, address indexed _sender);
    event externalPointsChanged(address indexed router, address indexed factory, address indexed reliableERC20, uint256 tributeShare);
    event PausedOrUnpaused();
    event BaseLiquidPoolInit(address indexed basePool, address indexed owner, uint lptokenAmount);
    /// ######### ERRORS #
    
    error EntryAlreadyExists();
    error ValueConditionNotMet();
    error PausedOrUninitialized();

    /// ######## Modifiers

    modifier isInit() {
        if (parentAuthPool[address(this)] == address(0)) revert("PausedOrUninitialized");
        _;
    }

    function setParentAuthPoolToZero(address _currentPoolAddr) external onlyOwner returns (address) {
        require(eligibilityShare > 0, "is default 0");

        emit PausedOrUnpaused();
        return parentAuthPool[address(this)] = parentAuthPool[address(this)] == _currentPoolAddr ? address(0) : _currentPoolAddr;
        
    }

    /// @inheritdoc IRegistry
    function setExternalPoints(address _router, address _factory, address _reliableERC20, uint256 _tributeShare, uint256 _reliableAmt, uint256 _a0zAmount) override external onlyOwner returns(address) {
        require(_router != address(0) && _factory != address(0) && _reliableERC20 != address(0) && _tributeShare >0, "zero val given");
        require(_reliableAmt * _a0zAmount > 0, "zero val given");
        if (_reliableERC20 != address(opToken)){
            opToken = IERC20(_reliableERC20);
        }


        if (_router != address(Router) || _factory !=  address(Factory)){
            Router = IUniswapV2Router(_router);
            Factory = IUniswapV2Factory(_factory);
        }



        if (Factory.getPair(address(opToken), address(this)) == address(0)) {

            parentAuthPool[address(this)] = Factory.createPair(address(this), address(opToken));

            require(opToken.transferFrom(msg.sender, address(this),_reliableAmt), "transfer failed");
            require(opToken.balanceOf(address(this)) >= _reliableAmt, "inssuficient _reliable balance"); //@dev necessary?
          
            require(opToken.approve(address(Router), MAX_UINT), "reliable amt");
            this.approve(parentAuthPool[address(this)],MAX_UINT);


            (,,uint liquid) = Router.addLiquidity(
                address(this),
                address(opToken),
                _a0zAmount,
                _reliableAmt,
                _a0zAmount,
                _reliableAmt, 
                owner,
                block.timestamp
            );
            require(liquid > 0, "addLiquid failed");

            IERC20(parentAuthPool[address(this)]).approve(msg.sender, MAX_UINT);

            emit BaseLiquidPoolInit(parentAuthPool[address(this)], owner, IUniswapV2Pair(parentAuthPool[address(this)]).balanceOf(owner));
            }
        

        if (_tributeShare != eligibilityShare ) eligibilityShare = _tributeShare;

        emit externalPointsChanged(address(Router), address(Factory), address(opToken), eligibilityShare);
        return parentAuthPool[address(this)];
    }

    /// @inheritdoc IRegistry
    function selfRegister(address _parentToken) override external isInit returns (address _pool) {
        if (parentAuthPool[_parentToken] != _pool) revert EntryAlreadyExists();
        uint256 initCost = calculateInitValue();

        address opParentPool = Factory.getPair(_parentToken, address(opToken));
        if ( opParentPool == address(0)) revert("provided&OP lp pool:not found");

        if (! ( opToken.transferFrom(msg.sender,address(this), initCost * 2 )) ) revert ValueConditionNotMet();
        /// @dev specify _parentToken quantity or assume^ existing opToken pool


        _pool = parentAuthPool[_parentToken] =  Factory.createPair(address(this),_parentToken);
        require(_pool != address(0), "poolCreateFail");
        
        require( IERC20(_parentToken).approve(address(Router), MAX_UINT) );

        address[] memory path1 = new address[](2);
        path1[0] = address(opToken);
        path1[1] = address(this);

        initCost = Router.swapExactTokensForTokens(initCost-2, 1, path1, address(this), block.timestamp +1)[1];


        require( IERC20(opToken).approve(address(Router), MAX_UINT) );
        path1[1] = _parentToken;
        uint _parentAmout = Router.swapExactTokensForTokens( IERC20(opToken).balanceOf(address(this)), 1, path1, address(this), block.timestamp + 1)[1];

        this.approve(address(Router), initCost); /// prevents transferFrom unbound overflow 

        (,,uint liquidity) = Router.addLiquidity(
            _parentToken,
            address(this),
            _parentAmout,
            initCost,
            1,
            1,
            address(this),
            block.timestamp
        );

        require( liquidity > 1, "SelfRegister Failed");
        
        // _mint(msg.sender, initCost); /// @dev tbd "free"

        emit selfRegistered(_parentToken, parentAuthPool[_pool], msg.sender);
    }

    /// ######### Internal #
    function transferFrom(address from, address to, uint256 amount) public override returns(bool) {
        /// @dev require? msg.sender || msg.sender == address(uint160(uint256(address(Router).codehash)))
        /// @dev add extra check here or rely on addLiquidity allowance. 
        /// @note this edge case should occur only once at self-registered time
        if (from == address(this) && to == parentAuthPool[address(this)]) {
            _mint(to, amount);
            return true;
        }
        return super.transferFrom(from,to,amount);
    }


    /// ######### Private #


    /// ######### VIEW #

    function calculateInitValue() public view override isInit returns (uint256 toPay) {
        toPay = totalSupply() / eligibilityShare;
        (uint a, uint b,) = IUniswapV2Pair(parentAuthPool[address(this)]).getReserves();
        (a,b) = IUniswapV2Pair(parentAuthPool[address(this)]).token0() == address(this) ? (a,b) : (b,a);
        toPay = Router.quote(toPay,a,b);
    }


    /// @inheritdoc IRegistry
    function getParentPool(address _OfSender) external view override returns (address) {
        return parentAuthPool[_OfSender];
    }


    /// @inheritdoc IRegistry
    function opTokenAddress() external view override returns (address) {
        return address(opToken);
    }

    /// @inheritdoc IRegistry
    function isRegistered(address _token) external view override returns (bool) {
     if (parentAuthPool[_token] != address(0)) return true;
    }

    /// @inheritdoc IRegistry
    function getOwner() external view override returns (address) {
        return owner;
    }

}
