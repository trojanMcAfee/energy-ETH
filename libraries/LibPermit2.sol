// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '../interfaces/IPermit2.sol';


library LibPermit2 {

    function getTokenPermission(
        IERC20 token_, 
        uint256 amount_
    ) internal pure returns(IPermit2.TokenPermissions memory permission) 
    {
        permission = IPermit2.TokenPermissions({
            token: token_,
            amount: amount_
        });
    }

    function getTokenAmounts(
        IERC20 token_, 
        uint256 fee_, 
        uint256 quote_
    ) internal pure returns(IPermit2.TokenPermissions[] memory amounts) 
    {
        amounts = new IPermit2.TokenPermissions[](2);
        amounts[0] = getTokenPermission(token_, fee_);
        amounts[1] = getTokenPermission(token_, quote_);
    }

    function getDetails(
        address receiver_, 
        uint256 amount_
    ) internal pure returns(IPermit2.SignatureTransferDetails memory details) 
    {
        details = IPermit2.SignatureTransferDetails({
            to: receiver_,
            requestedAmount: amount_
        });
    }


    function getTransferDetails(
        address feeReceiver_,
        address quoteReceiver_,
        uint256 fee_, 
        uint256 quote_
    ) internal pure returns(IPermit2.SignatureTransferDetails[] memory details) 
    {
        details = new IPermit2.SignatureTransferDetails[](2);
        details[0] = getDetails(feeReceiver_, fee_);
        details[1] = getDetails(quoteReceiver_, quote_);
    }
}