//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;

contract Test {
    event Deposit(address indexed _from, bytes32 indexed _id, uint _value);
    function deposit(bytes32 _id) public payable {
        emit Deposit(msg.sender, _id, msg.value);
    }
}
