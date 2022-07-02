// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
import "solmate/tokens/ERC20.sol";

contract DAOToken is ERC20("CommunityValueToken","CVT",18) {

    constructor(){
        _mint(msg.sender,(1000 * 10 ** 18));
    }
}