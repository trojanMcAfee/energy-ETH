// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import '@rari-capital/solmate/src/utils/FixedPointMathLib.sol';


library LibHelpers {

    using FixedPointMathLib for uint256;


    function calculateSlippage(
        uint256 amount_, 
        uint256 basisPoint_
    ) internal pure returns(uint256 minAmountOut) {
        minAmountOut = amount_ - amount_.mulDivDown(basisPoint_, 10000);
    }


    function getFee(uint256 amount_, uint256 protocolFee_) internal view returns(uint, uint) {
        uint256 fee = amount_ - calculateSlippage(amount_, protocolFee_);
        uint256 netAmount = amount_ - fee;
        return (netAmount, fee);
    }

}