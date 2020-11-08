//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract WhitelistAddressManager is Ownable {

    address internal whitelistAddress;

    constructor (address initialWhitelistAddress) internal {
        whitelistAddress = initialWhitelistAddress;
    }

    function updateWhitelist(address newWhiteListAddress) public onlyOwner {
        whitelistAddress = newWhiteListAddress;
    }
}
