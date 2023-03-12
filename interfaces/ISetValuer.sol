// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import './ISetToken.sol';

interface ISetValuer {

    function calculateSetTokenValuation(ISetToken _setToken, address _quoteAsset) external view returns (uint256);

}