// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract ThirdToken is ERC20("UniversalValueToken","UVT") {

    constructor(){
        _mint(msg.sender,(1001 * 10 ** 18));
        _mint(address(1337),(1001 * 10 ** 18));
        _mint(address(306),(90000 * 10 ** 18));
    }
}

// import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
// import "uniswapv2-solc0.8/contracts/interfaces/IERC20.sol";