// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '../interfaces/ozIDiamond.sol';
import '../interfaces/IPermit2.sol';
import '../libraries/LibHelpers.sol';
import '../libraries/LibPermit2.sol';


error Cant_be_zero();
error Not_enough_funds(uint256 buyerBalance);
error Cant_approve(uint256 amount);
error Cant_transfer(uint256 amount);



/**
 * @title eETH as an ERC20 token.
 * @notice Makes eETH ERC20 complaint + the logic to issue new tokens.
 */
contract EnergyETH is ERC20 {

    using LibPermit2 for *;

    IERC20 USDC = IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);
    IERC20 USDT = IERC20(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9);
    
    ozIDiamond OZL = ozIDiamond(0x7D1f13Dd05E6b0673DC3D0BFa14d40A74Cfa3EF2);
    IPermit2 immutable PERMIT2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    constructor() ERC20('Energy ETH', 'eETH') {}


    /**
     * @dev Queries eETH price from ozOracleFacet through ozDiamond.
     * @return price of eETH
     */
    function getPrice() public view returns(uint256) {
        return OZL.getEnergyPrice();
    }


    /**
     * @dev Issues eETH, with its proper index valuation, from external feeds 
     * (WTI and Gold), and deposits the protocol fee into DeFi.
     * @param buyOp_ contains the details of the buy order for eETH following Permit2.
     */
    function issue(IPermit2.Permit2Buy memory buyOp_) external payable {
        uint256 toBuy = buyOp_.amount;
        if (toBuy == 0) revert Cant_be_zero();

        uint256 quote = (toBuy * getPrice()) / 10 ** 12;
        uint256 buyerBalance = buyOp_.token.balanceOf(msg.sender);

        if (buyerBalance < quote) revert Not_enough_funds(buyerBalance);

        (, uint256 fee) = LibHelpers.getFee(quote, OZL.getProtocolFee());
        
        buyOp_.amount = quote + fee; 

        _issue(buyOp_, quote, fee);

        _mint(msg.sender, toBuy);

        OZL.depositFeesInDeFi(fee, false);
    }


    /**
     * @dev Does the issuance heavy lifting. 
     * @param buyOp_ buy order details under Permit2. 
     * @param quote_ how much value in total of eETH to buy.
     * @param fee_ protocol fee.
     */
    function _issue(
        IPermit2.Permit2Buy memory buyOp_,
        uint256 quote_,
        uint256 fee_
    ) private {
        IPermit2.TokenPermissions[] memory amounts = buyOp_.token.getTokenAmounts(fee_, quote_);

        IPermit2.PermitBatchTransferFrom memory permit = IPermit2.PermitBatchTransferFrom({
            permitted: amounts,
            nonce: buyOp_.nonce,
            deadline: buyOp_.deadline
        });

        IPermit2.SignatureTransferDetails[] memory details = 
            address(OZL).getTransferDetails(address(this), fee_, quote_);

        PERMIT2.permitTransferFrom(permit, details, msg.sender, buyOp_.signature);
    }
}

