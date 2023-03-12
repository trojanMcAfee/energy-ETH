// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

import 'hardhat/console.sol';

contract EnergyETH is ERC20 {

    AggregatorV3Interface private priceFeed;

    
    constructor(address priceFeed_) ERC20('Energy ETH', 'eETH') {
        priceFeed = AggregatorV3Interface(priceFeed_);
    }


    function getPrice() public view returns(uint256) {
        (,int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price);
    }



}