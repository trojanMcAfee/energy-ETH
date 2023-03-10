// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;


import '../interfaces/ISetTokenCreator.sol';
import './INavModule.sol';

import 'hardhat/console.sol';


contract CreateSet {

    ISetTokenCreator tokenCreator;
    INavModule navModule;

    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    struct NAVIssuanceSettings {
        INAVIssuanceHook managerIssuanceHook;      
        INAVIssuanceHook managerRedemptionHook;        
        address[] reserveAssets;                       
        address feeRecipient;                          
        uint256[2] managerFees;                        
        uint256 maxManagerFee;                         
        uint256 premiumPercentage;                                                                        
        uint256 maxPremiumPercentage;                  
        uint256 minSetTokenSupply;                  
    }


    constructor(
        address creator_,
        address navMod_
    ) {
        tokenCreator = ISetTokenCreator(creator_);
        navModule = INavModule(navMod_);
    }


    function createSet() public returns(address) {
        address[] memory components = new address[](2);
        int256[] memory units = new int256[](2);
        address[] memory modules = new address[](1);
        address[] memory reserve = new address[2];
        uint256[2] managerFees; 

        components[0] = WETH;
        components[1] = WBTC;
        units[0] = 2 * 1e18;
        units[1] = 3 * 1e18;
        modules[0] = navModule;
        reserve[0] = WETH;
        reserve[1] = USDC;
        managerFees[0] = 1e16;
        managerFees[1] = 1e16;

        address set = tokenCreator.create(
            components,
            units,
            modules,
            msg.sender,
            'Energy ETH',
            'eETH'
        );

        console.log('set: ', set);
        return set;
    }


    function createNInit() public {
        address set = createSet();

        NAVIssuanceSettings config = NAVIssuanceSettings(
            managerIssuanceHook: address(0),
            managerRedemptionHook: address(0),
            
        );

        navModule.initialize(
            address(0),
            address(0),
            reserve,
            msg.sender,
            managerFees,
            1e18,
            5e15,
            5
        );

           INAVIssuanceHook managerIssuanceHook;      
        INAVIssuanceHook managerRedemptionHook;        
        address[] reserveAssets;                       
        address feeRecipient;                          
        uint256[2] managerFees;                        
        uint256 maxManagerFee;                         
        uint256 premiumPercentage;                                                                        
        uint256 maxPremiumPercentage;                  
        uint256 minSetTokenSupply;


    }

}