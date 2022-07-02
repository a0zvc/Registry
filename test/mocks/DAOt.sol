// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
import "solmate/tokens/ERC20.sol";

contract DAOToken is ERC20("CommunityValueToken","CVT",18) {
    address ofthis;
    constructor(){
        ofthis = address(this);
        _mint(msg.sender,(1000 * 10 ** 18));
    }

    function changeOfthis() public returns (bool) {
        ofthis = address(0);
    }
}