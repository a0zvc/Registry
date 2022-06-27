pragma solidity >=0.8.0;

import "solmate/tokens/ERC20.sol";
import "solmate/auth/Owned.sol";

import "uniswapv2-solc0.8/interfaces/IUniswapV2Router.sol";
import "uniswapv2-solc0.8/interfaces/IUniswapV2Factory.sol";
import "uniswapv2-solc0.8/interfaces/IUniswapV2Pair.sol";
// import "uniswapv2-solc0.8/contracts/interfaces/IUniswapV2Pair.sol";

import "uniswapv2-solc0.8/interfaces/IERC20.sol";
import "./IRegistry.sol";

contract Registry is 
    ERC20("A0Z.VC", "A0Z", 18),
    Owned(msg.sender),
    IRegistry 
{
        IUniswapV2Router Router;
        IUniswapV2Factory Factory;
        IERC20 thirdToken;

        constructor(address _chairperson){
            require(_chairperson != address(0), "address 0");
            owner = _chairperson;
        }

    mapping(address => address) parentAuthPool;

    uint256 eligibilityShare;

    /// ######### Events #

    event selfRegistered(address indexed _parentToken, address indexed _pool, address indexed _sender);

    /// ######### ERRORS #
    
    error EntryAlreadyExists();
    error ValueConditionNotMet();
    error PausedOrUninitialized();


    /// ######## Modifiers

    modifier isInit() {
        if (parentAuthPool[address(this)] == address(0)) revert("PausedOrUninitialized");
        _;
    }

    function setParentAuthPoolToZero(address _currentPoolAddr) external onlyOwner returns (bool) {
        require(eligibilityShare > 0, "is default 0");
        parentAuthPool[address(this)] = parentAuthPool[address(this)] == _currentPoolAddr ? address(0) : _currentPoolAddr;
    }

    /// @inheritdoc IRegistry
    function setExternalPoints(address _router, address _factory, address _reliableERC20, uint256 _tributeShare) override external onlyOwner returns(bool) {
        Router = IUniswapV2Router(_router);
        Factory = IUniswapV2Factory(_factory);
        thirdToken = IERC20(_reliableERC20);

        eligibilityShare = _tributeShare;
        parentAuthPool[address(this)] = Factory.createPair(_reliableERC20, address(this));

    }

    /// @inheritdoc IRegistry
    function selfRegister(address _parentToken) override external isInit returns (address _pool) {
        if (parentAuthPool[msg.sender] != _pool) revert EntryAlreadyExists();
        assembly { _pool := 1 } // nonReentrant
        uint256 initCost = calculateInitValue();
        if (! ( thirdToken.transferFrom(msg.sender,address(this), initCost * 2 )) ) revert ValueConditionNotMet();
        parentAuthPool[msg.sender] =  Factory.createPair(address(this),_parentToken);
        address[] memory path1;
        path1[0] = address(thirdToken);
        path1[1] = address(this);

        initCost = Router.swapExactTokensForTokens(initCost, 1, path1, address(this), block.timestamp)[1];

        path1[1] = _parentToken;

        Router.addLiquidity(
            address(this),
            _parentToken,
            initCost,
            Router.swapExactTokensForTokens(initCost, 1, path1, address(this), block.timestamp)[1],
            1,
            1,
            parentAuthPool[msg.sender],
            block.timestamp
        );

        _mint(msg.sender, initCost);

        emit selfRegistered(_parentToken, parentAuthPool[msg.sender], msg.sender);
    }


    /// ######### Internal #



    /// ######### Private #


    /// ######### VIEW #


    function calculateInitValue() public view override isInit returns (uint256 toPay) {
        toPay = totalSupply / eligibilityShare;
        (uint a, uint b,) = IUniswapV2Pair(parentAuthPool[address(this)]).getReserves();
        (a,b) = IUniswapV2Pair(parentAuthPool[address(this)]).token0() == address(this) ? (a,b) : (b,a);
        toPay = Router.quote(toPay,a,b);
    }

    /// @inheritdoc IRegistry
    function getParentPool(address _OfSender) external view override returns (address) {
        return parentAuthPool[_OfSender];
    }


    /// @inheritdoc IRegistry
    function thirdTokenAddress() external view override returns (address) {
        return address(thirdToken);
    }

}

