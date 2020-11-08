//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.9;

import "./lib/ERC1404/ERC1404.sol";
import "./lib/whitelist/WhitelistAddressManager.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ManagedWhitelist.sol";

contract AssetToken is ERC20, ERC1404, WhitelistAddressManager {

    uint8 public constant SUCCESS_CODE = 0;
    uint8 public constant SEND_NOT_ALLOWED_CODE = 1;
    uint8 public constant RECEIVE_NOT_ALLOWED_CODE = 2;

    string public constant ERROR_CODE_UNKNOWN = "ERROR_CODE_UNKNOWN";
    string public constant SUCCESS_MESSAGE = "SUCCESS";
    string public constant SEND_NOT_ALLOWED_ERROR = "ILLEGAL_TRANSFER_SENDING_ACCOUNT_NOT_WHITELISTED";
    string public constant RECEIVE_NOT_ALLOWED_ERROR = "ILLEGAL_TRANSFER_RECEIVING_ACCOUNT_NOT_WHITELISTED";

    constructor (string memory name, string memory symbol, uint256 amount, address issuer, address initialWhitelistAddress) public ERC20(name, symbol) WhitelistAddressManager(initialWhitelistAddress) {
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
        ManagedWhitelist m = ManagedWhitelist(whitelistAddress);

        if (!m.sendAuthorized(from)) {
            restrictionCode = SEND_NOT_ALLOWED_CODE;
        } else if (!m.receiveAuthorized(to)) {
            restrictionCode = RECEIVE_NOT_ALLOWED_CODE;
        } else {
            restrictionCode = SUCCESS_CODE;
        }
    }

    //@Override
    function messageForTransferRestriction (uint8 calldata restrictionCode) override public view returns (string memory message)
    {
        if(restrictionCode == SUCCESS_CODE){
            message = SUCCESS_MESSAGE;
        } else if (restrictionCode == SEND_NOT_ALLOWED_CODE) {
            message = SEND_NOT_ALLOWED_ERROR;
        } else if (restrictionCode == RECEIVE_NOT_ALLOWED_CODE){
            message = RECEIVE_NOT_ALLOWED_ERROR;
        } else {
            message = ERROR_CODE_UNKNOWN;
        }
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