pragma solidity >=0.8.0;

import "solmate/tokens/ERC20.sol";
import "solmate/auth/Owned.sol";

import "uniswapv2-solc0.8/interfaces/IUniswapV2Router.sol";
import "uniswapv2-solc0.8/interfaces/IUniswapV2Factory.sol";
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
            owner = _chairperson;
        }

    /// @inheritdoc IRegistry
    function setExternalPoints(address _router, address _factory, address _reliableERC20) override external onlyOwner returns(bool) {
        Router = IUniswapV2Router(_router);
        Factory = IUniswapV2Factory(_factory);
        thirdToken = IERC20(_reliableERC20);
    }


}

