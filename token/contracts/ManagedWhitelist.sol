//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.9;

import "./lib/whitelist/Managed.sol";

contract ManagedWhitelist is Managed {

    mapping (address => bool) internal sendAllowed;
    mapping (address => bool) internal receiveAllowed;

    modifier onlySendAllowed {
        require(sendAllowed[msg.sender], "Sender is not whitelisted");
        _;
    }

    modifier onlyReceiveAllowed {
        require(receiveAllowed[msg.sender], "Recipient is not whitelisted");
        _;
    }

    function sendAuthorized(address from, uint value) public view returns (bool) {
        return sendAllowed[from];
    }

    function receiveAuthorized(address to, uint value) public view returns (bool) {
        return receiveAllowed[to];
    }

    function addToSendAllowed (address operator) public onlyManagerOrOwner {
        sendAllowed[operator] = true;
    }

    function addToReceiveAllowed (address operator) public onlyManagerOrOwner {
        receiveAllowed[operator] = true;
    }

    function addToBothSendAndReceiveAllowed (address operator) public onlyManagerOrOwner {
        addToSendAllowed(operator);
        addToReceiveAllowed(operator);
    }

    function removeFromSendAllowed (address operator) public onlyManagerOrOwner {
        sendAllowed[operator] = false;
    }

    function removeFromReceiveAllowed (address operator) public onlyManagerOrOwner {
        receiveAllowed[operator] = false;
    }

    function removeFromBothSendAndReceiveAllowed (address operator) public onlyManagerOrOwner {
        removeFromSendAllowed(operator);
        removeFromReceiveAllowed(operator);
    }

}
