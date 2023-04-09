// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '../../interfaces/ITri.sol';
import '../../interfaces/IYtri.sol';
import '../../interfaces/ozIExecutorFacet.sol';
import '../AppStorage.sol';

import "forge-std/console.sol";


contract ozExecutor2Facet {

    AppStorage s;

    //put a modifier here that only eETH can call this function
    //msg.sender is eETH (checked)


    function depositFeesInDeFi(uint fee_, bool isRetry_) external { 
        /// @dev Into Curve's Tricrypto
        (uint tokenAmountIn, uint[3] memory amounts) = _calculateTokenAmountCurve(fee_);

        IERC20(s.USDT).approve(s.tricrypto, tokenAmountIn);

        for (uint i=1; i <= 2; i++) {
            uint minAmount = ozIExecutorFacet(s.executor).calculateSlippage(tokenAmountIn, s.defaultSlippage * i);

            try ITri(s.tricrypto).add_liquidity(amounts, minAmount) {
                /// @dev Into Yearn's crvTricrypto
                IERC20(s.crvTricrypto).approve(
                    s.yTriPool, IERC20(s.crvTricrypto).balanceOf(address(this))
                );

                IYtri(s.yTriPool).deposit(IERC20(s.crvTricrypto).balanceOf(address(this)));

                /// @dev Internal fees accounting
                if (s.failedFees > 0) s.failedFees = 0;
                s.feesVault += fee_;
                
                break;
            } catch {
                if (i == 1) {
                    continue;
                } else {
                    if (!isRetry_) s.failedFees += fee_; 
                }
            }
        }
    }


    function _calculateTokenAmountCurve(uint amountIn_) private view returns(uint, uint[3] memory) {
        uint[3] memory amounts;
        amounts[0] = amountIn_;
        amounts[1] = 0;
        amounts[2] = 0;
        uint tokenAmount = ITri(s.tricrypto).calc_token_amount(amounts, true);
        return (tokenAmount, amounts);
    }



}