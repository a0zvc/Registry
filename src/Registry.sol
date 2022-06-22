pragma solidity >=0.8.0;

import "solmate/tokens/ERC20.sol";
import "solmate/auth/Owned.sol";
import "uniswapv2-solc0.8/UniswapV2Router.sol";
import "uniswapv2-solc0.8/UniswapV2Factory.sol";


contract Registry is 
    ERC20("A0Z.VC", "A0Z", 18),
    UniswapV2Factory(address(this)),
    UniswapV2Router(address(this), address(0)), //import code or call via interface
    Owned(msg.sender)
     {

        constructor(address _chairperson){
            owner = _chairperson;
        }



     }

