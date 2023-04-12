// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


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
}