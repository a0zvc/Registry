// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";


contract DAOToken is ERC20("CommunityValueToken","CVT") {
    address ofthis;
    constructor(){
        ofthis = address(this);
        _mint(address(1337),(10000 * 10 ** 18));
        _mint(address(306),(900000 * 10 ** 18));
    }

    /// @dev fluff function added for clear createcode diff for trace contract flicker bug
    // function changeOfthis() public returns (bool) {
    //     ofthis = address(99);
    //     return true;
    // }
}