// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '../../interfaces/ITri.sol';
import '../../interfaces/IYtri.sol';
import '../../interfaces/ozIExecutorFacet.sol';
import '../AppStorage.sol';


/**
 * @title 2nd version of Executing contract for main account functions.
 * @notice It extends the scope of usage of a key function so it can be
 * called externally.  
 */
contract ozExecutor2Facet {

    AppStorage s;

    //put a modifier here that only eETH can call this function
    //msg.sender is eETH (checked)

    /**
     * @dev External implementation of _depositFeesInDeFi() from OZLFacet on v1. 
     * @notice Opens this function, as external, from Ozel v1 so it can be used
     * by external parties, like eETH, and deposit the protocol fees into Defi.
     * @param fee_ fee to deposit into DeFi.
     * @param isRetry_ bool flag to determining if the call is for retrying a failed 
     * attempt of deposing fees or not. 
     */
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


    /**
     * @dev Calculates the amounts of token needed for Curve swaps. 
     * @param amountIn_ amount going in into the swap. 
     * @return output from Curve's virtual function (calc_token_amount).
     * @return array with amountIn_ (format needed by Curve).
     */
    function _calculateTokenAmountCurve(uint amountIn_) private view returns(uint, uint[3] memory) {
        uint[3] memory amounts;
        amounts[0] = amountIn_;
        amounts[1] = 0;
        amounts[2] = 0;
        uint tokenAmount = ITri(s.tricrypto).calc_token_amount(amounts, true);
        return (tokenAmount, amounts);
    }
}