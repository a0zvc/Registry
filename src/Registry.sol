pragma solidity 0.8.15;

import "solmate/tokens/ERC20.sol";
import "solmate/auth/Owned.sol";
import "uniswapv2-solc0.8/UniswapV2Router02.sol";
import "uniswapv2-solc0.8/UniswapV2Factory.sol";


contract Registry is 
    ERC20("A0Z.VC", "A0Z", 18),
    UniswapV2Factory("10"), //@todo deploy and link in constructor via interface
    UniswapV2Router02(address(this), address(0)),
    Owned(msg.sender)
     {

        constructor(address _chairperson){
            owner = _chairperson;
        }



     }

