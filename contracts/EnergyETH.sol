// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

import 'hardhat/console.sol';

contract EnergyETHFacet is ERC20 {

    AggregatorV3Interface private wtiFeed;
    AggregatorV3Interface private volatilityFeed;
    AggregatorV3Interface private ethUsdFeed;

    
    constructor(
        address wtiFeed_,
        address volatilityFeed_,
        address ethUsdFeed_
    ) ERC20('Energy ETH', 'eETH') {
        wtiFeed = AggregatorV3Interface(wtiFeed_);
        volatilityFeed = AggregatorV3Interface(volatilityFeed_);
        ethUsdFeed = AggregatorV3Interface(ethUsdFeed_);
    }


    function getPrice() public view returns(uint256, uint256, uint256) {
        (,int256 oilPrice,,,) = wtiFeed.latestRoundData();
        (,int256 volPrice,,,) = volatilityFeed.latestRoundData();
        (,int256 ethPrice,,,) = ethUsdFeed.latestRoundData();
        
        return (
            uint256(oilPrice),
            uint256(volPrice),
            uint256(ethPrice)
        );
    }



}