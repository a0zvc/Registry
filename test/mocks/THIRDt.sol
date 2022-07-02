// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
import "solmate/tokens/ERC20.sol";

contract ThirdToken is ERC20("UniversalValueToken","UVT",18) {

    constructor(){
        _mint(msg.sender,(1001 * 10 ** 18));
    }
}

// import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
// import "uniswapv2-solc0.8/contracts/interfaces/IERC20.sol";