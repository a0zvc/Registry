pragma solidity 0.8.12;

import "solmate/tokens/ERC20.sol";
import "solmate/auth/Owned.sol";
import "v2-periphery/UniswapV2Router02.sol";
import "v2-core/UniswapV2Factory.sol";

contract Registry is 
    ERC20("A0Z.VC", "A0Z", 18),
    UniswapV2Factory("10"),
    UniswapV2Router02(address(this), address(0)),
    Owned(msg.sender)
     {


        constructor(address _weth, address _chairperson){
            WETH = _weth;
            owenr = _chairperson;
        }



     }

