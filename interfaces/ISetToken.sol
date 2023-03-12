// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;




interface ISetToken {

    struct Position {
        address component;
        address module;
        int256 unit;
        uint8 positionState;
        bytes data;
    }

    function manager() external view returns (address);
    function getModules() external view returns (address[] memory);
    function getPositions() external view returns (Position[] memory);
    function getComponents() external view returns (address[] memory);
    function getDefaultPositionRealUnit(address _component) external view returns (int256);
    function getExternalPositionRealUnit(address _component, address _positionModule) external view returns(int256);
    function getTotalComponentRealUnits(address _component) external view returns(int256);

    function balanceOf(address user_) external view returns (uint256);

}