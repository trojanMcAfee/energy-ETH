// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// import '../contracts/AppStorage.sol';

interface ozIDiamond {

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    enum FacetCutAction {Add, Replace, Remove}

    function diamondCut(FacetCut[] memory _diamondCut, address _init, bytes memory _calldata) external;
    function getLastPrice() external view returns(uint256);
    function getEnergyPrice() external view returns(uint256);
    function getOzelIndex() external view returns(uint256);
    function getProtocolFee() external view returns(uint256);
    function depositFeesInDeFi(uint256 fee_, bool isRetry_) external;
    function getFeesVault() external view returns(uint256);
    function getAUM() external view returns(uint256 wethUM, uint256 valueUM);
    function getOracles() external view returns(address[] memory);
    function getOracleIdByAddress(address oracle_) external view returns(bytes32);
    function getOracleAddressById(bytes32 id_) external view returns(address);
    function addOracle(address newOracle_, bytes32 id_) external;
    function removeOracle(address toRemove_) external;
    function getVolatilityIndex() external view returns(int256);
    function changeVolatilityIndex(AggregatorV3Interface newFeed_) external;
    function addFeed(AggregatorV3Interface newFeed_) external;
    function removeFeed(AggregatorV3Interface toRemove_) external;
    function getPriceFeeds() external returns(address[] memory feeds);
    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
    function getUniPool() external view returns(address);
    function changeUniPool(address newPool_) external;
}