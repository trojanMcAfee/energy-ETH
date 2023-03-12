// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;


import './ISetToken.sol';
import './INAVIssuanceHook.sol';


interface INavModule {

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


    function initialize(
        ISetToken _setToken,
        NAVIssuanceSettings memory _navIssuanceSettings
    ) external;

    function getReserveAssets(ISetToken _setToken) external view returns (address[] memory);

    function issue(
        ISetToken _setToken,
        address _reserveAsset,
        uint256 _reserveAssetQuantity,
        uint256 _minSetTokenReceiveQuantity,
        address _to
    ) external;

    function issueWithEther(
        ISetToken _setToken,
        uint256 _minSetTokenReceiveQuantity,
        address _to
    ) external payable;


}