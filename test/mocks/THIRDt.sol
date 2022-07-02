// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
import "solmate/tokens/ERC20.sol";

contract ThirdToken is ERC20("UniversalValueToken","UVT",18) {

    constructor(){
        _mint(msg.sender,(1000 * 10 ** 18));
    }
}