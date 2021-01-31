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

    // How many token units a buyer gets per DAI. 120 = 1.2 tokens per dai.
    uint256 _ratePerDai;

    constructor(uint256 ratePerDai, address payable storageWalletAddress, address assetTokenAddress, address uniswapAddress, address daiAddress) public {
        _ratePerDai = ratePerDai;
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

        //Ensure there's enough tokens to cover
        require(tokens >= getRemainingDistributionQuantity(), "Not enough tokens remaining. Please specify exact amount");

        //deliver tokens
        processPurchase(beneficiary, tokens);

        //audit trail
        emit TokensPurchasedWithEth(msg.sender, beneficiary, msg.value, tokens);
    }

    function buyTokensWithDai(address beneficiary, uint256 daiAmount) public nonReentrant {
        //Sanity check
        preValidatePurchase(beneficiary, daiAmount);

        //Transfer the tokens from the user to us
        require(transferDaiFromBeneficiary(beneficiary, daiAmount), "Unable to transfer tokens from beneficiary");

        // calculate token amount purchased
        uint256 tokens = getTokenAmount(daiAmount);

        //Ensure there's enough tokens to cover
        require(tokens >= getRemainingDistributionQuantity(), "Not enough tokens remaining. Please specify exact amount");

        //deliver tokens
        processPurchase(beneficiary, tokens);

        //audit trail
        emit TokensPurchasedWithDai(msg.sender, beneficiary, daiAmount, tokens);
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

    function preValidatePurchase(address beneficiary, uint256 amount) internal view {
        require(beneficiary != address(0), "Beneficiary is the zero address");
        require(amount != 0, "Amount is 0");
        require(getRemainingDistributionQuantity() > 0, "Asset has been fully distributed");
    }

    function getTokenAmount(uint256 daiAmount) internal view returns (uint256) {
        return daiAmount.mul(_ratePerDai).div(100);
    }

    function processPurchase(address beneficiary, uint256 tokenAmount) internal {
        deliverTokens(beneficiary, tokenAmount);
    }

    function deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        IERC20 assetToken = IERC20(_assetTokenAddress);

        assetToken.transfer(beneficiary, tokenAmount);
    }

    function convertEthToDai(uint256 quantity) internal returns (uint256) {
        IUniswapV2Router01 uniswap = IUniswapV2Router01(_uniswapAddress);

        address[] memory path = new address[](2);
        path[0] = uniswap.WETH();
        path[1] = _daiAddress;

        uint[] memory amounts = uniswap.swapExactETHForTokens{value: quantity}(0, path, _storageWalletAddress, block.timestamp);

        return amounts[1];
    }

    function getRemainingDistributionQuantity() internal view returns (uint256){
        return IERC20(_assetTokenAddress).balanceOf(address(this));
    }

    function transferDaiFromBeneficiary(address beneficiary, uint256 quantity) internal returns (bool) {
        return IERC20(_daiAddress).transferFrom(beneficiary, _storageWalletAddress, quantity);
    }

    receive() external payable {
        buyTokensWithEth(msg.sender);
    }

    function selfDestruct() public onlyOwner {
        IERC20(_assetTokenAddress).transfer(_storageWalletAddress, IERC20(_assetTokenAddress).balanceOf(address(_storageWalletAddress)));
        selfDestruct();
    }

    event TokensPurchasedWithEth(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event TokensPurchasedWithDai(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
}