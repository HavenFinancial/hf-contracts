//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.9;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/GSN/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Crowdsale is ReentrancyGuard, Ownable {
    using SafeMath for uint256;

    // The token address being sold
    address private _assetTokenAddress;

    // the DAI contract address
    address private _daiAddress;

    // The uniswap router address
    address private _uniswapAddress;

    // Address where funds are collected
    address payable private _storageWalletAddress;

    // How many token units a buyer gets per DAI.
    uint256 _ratePerDai;

    // Amount of DAI raised
    uint256 _daiRaised;

    // Total amount of tokens to distribute
    uint256 private _distributionQuantity;

    constructor(uint256 ratePerDai, uint256 distributionQuantity, address payable storageWalletAddress, address assetTokenAddress, address uniswapAddress, address daiAddress) public {
        _ratePerDai = ratePerDai;
        _distributionQuantity = distributionQuantity;
        _storageWalletAddress = storageWalletAddress;
        _assetTokenAddress = assetTokenAddress;
        _uniswapAddress = uniswapAddress;
        _daiAddress = daiAddress;
    }

    function buyTokensWithEth(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;

        //Sanity check
        preValidatePurchase(beneficiary, weiAmount);

        //Convert to DAI
        uint256 daiAmount = convertEthToDai(weiAmount);

        // calculate token amount purchased
        uint256 tokens = getTokenAmount(daiAmount);

        //deliver tokens
        processPurchase(beneficiary, tokens);

        // update state
        _daiRaised = _daiRaised.add(daiAmount);

        //Send the funds
        forwardDai(daiAmount);

        emit TokensPurchased(msg.sender, beneficiary, daiAmount, tokens);
    }

    function buyTokensWithDai(address beneficiary, uint256 amountDai) public nonReentrant payable {
        //TODO

        //Sanity check
        preValidatePurchase(beneficiary, amountDai);
    }

    function updateAssetTokenAddress(address assetTokenAddress) public onlyOwner {
        _assetTokenAddress = assetTokenAddress;
    }

    function updateUniswapAddress(address uniswapAddress) public onlyOwner {
        _uniswapAddress = uniswapAddress;
    }

    function updateWalletAddress(address payable storageWalletAddress) public onlyOwner {
        _storageWalletAddress = storageWalletAddress;
    }

    function updateDaiAddress(address daiAddress) public onlyOwner {
        _daiAddress = daiAddress;
    }

    function preValidatePurchase(address beneficiary, uint256 amount) internal pure {
        require(beneficiary != address(0), "Beneficiary is the zero address");
        require(amount != 0, "Amount is 0");
    }

    function getTokenAmount(uint256 daiAmount) internal view returns (uint256) {
        return daiAmount.mul(_ratePerDai);
    }

    function processPurchase(address beneficiary, uint256 tokenAmount) internal {
        deliverTokens(beneficiary, tokenAmount);
    }

    function deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        IERC20 assetToken = IERC20(_assetTokenAddress);

        assetToken.transfer(beneficiary, tokenAmount);
    }

    function forwardDai(uint256 quantity) internal {
        IERC20 daiToken = IERC20(_daiAddress);

        daiToken.transfer(_storageWalletAddress, quantity);
    }

    function convertEthToDai(uint256 quantity) internal returns (uint256) {
        IUniswapV2Router01 uniswap = IUniswapV2Router01(_uniswapAddress);

        address[] memory path = new address[](2);
        path[0] = uniswap.WETH();
        path[1] = _daiAddress;

        uint[] memory amounts = uniswap.swapExactETHForTokens{value: quantity}(0, path, _storageWalletAddress, block.timestamp);
        //TODO check there's enough tokens tokens left to distribute, if not they'll need ETH change

        //TODO return the ETH dust

        return amounts[1];
    }

    receive() external payable {
        buyTokensWithEth(msg.sender);
    }

    //TODO add self destruct which returns all tokens to given address

    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
}