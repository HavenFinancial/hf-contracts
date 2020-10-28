//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.9;

import "lib/ERC1404/ERC1404.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AssetERC1404 is ERC20, ERC1404{

    uint8 public constant SUCCESS_CODE = 0;
    uint8 public constant SEND_NOT_ALLOWED_CODE = 1;
    uint8 public constant RECEIVE_NOT_ALLOWED_CODE = 2;

    string public constant SUCCESS_MESSAGE = "SUCCESS";
    string public constant SEND_NOT_ALLOWED_ERROR = "ILLEGAL_TRANSFER_SENDING_ACCOUNT_NOT_WHITELISTED";
    string public constant RECEIVE_NOT_ALLOWED_ERROR = "ILLEGAL_TRANSFER_RECEIVING_ACCOUNT_NOT_WHITELISTED";

    constructor (string memory name, string memory symbol, uint256 amount, address issuer) public ERC20(name, symbol) {
        _mint(issuer, amount);
    }

    modifier notRestricted (address from, address to, uint256 value) {
        uint8 restrictionCode = detectTransferRestriction(from, to, value);
        require(restrictionCode == SUCCESS_CODE, messageForTransferRestriction(restrictionCode));
        _;
    }

    //@Override
    function detectTransferRestriction(address from, address to, uint value) public override view returns (uint8 restrictionCode)
    {
//        if (!sendAllowed[from]) {
//            restrictionCode = SEND_NOT_ALLOWED_CODE;
//            // sender address not whitelisted
//        } else if (!receiveAllowed[to]) {
//            restrictionCode = RECEIVE_NOT_ALLOWED_CODE;
//            // receiver address not whitelisted
//        } else {
//            restrictionCode = SUCCESS_CODE;
//            // successful transfer (required)
//        }

        restrictionCode = SUCCESS_CODE;
    }

    //@Override
    function messageForTransferRestriction (uint8 restrictionCode) override public view returns (string memory message)
    {
//        if (!sendAllowed[from]) {
//            message = SEND_NOT_ALLOWED_ERROR;
//        } else if (!receiveAllowed[to]) {
//            message = RECEIVE_NOT_ALLOWED_ERROR;
//        } else {
//            message = SUCCESS_MESSAGE;
//        }

        message = SUCCESS_MESSAGE;
    }

    //@Override
    function transfer (address to, uint256 value) override public notRestricted(msg.sender, to, value) returns (bool success)
    {
        success = super.transfer(to, value);
    }

    //@Override
    function transferFrom (address from, address to, uint256 value) override public notRestricted(from, to, value) returns (bool success)
    {
        success = super.transferFrom(from, to, value);
    }
}