// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '../interfaces/ozIDiamond.sol';
import '../interfaces/IPermit2.sol';
import '../interfaces/ITri.sol';
import '../interfaces/IYtri.sol';
import '../libraries/LibHelpers.sol';
// import './ozOracleFacet.sol';

import "forge-std/console.sol";
// import 'hardhat/console.sol';


error Cant_be_zero();
error Not_enough_funds(uint256 buyerBalance);
error Cant_approve(uint256 amount);
error Cant_transfer(uint256 amount);


contract EnergyETH is ERC20 {

    IERC20 USDC = IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);
    IERC20 USDT = IERC20(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9);
    IERC20 crvTricrypto = IERC20(0x8e0B8c8BB9db49a46697F3a5Bb8A308e744821D2);

    address immutable wethAdrr = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    
    IYtri yTriPool = IYtri(0x239e14A19DFF93a17339DCC444f74406C17f8E67);
    ITri tricrypto = ITri(0x960ea3e3C7FB317332d990873d354E18d7645590);
    ozIDiamond OZL = ozIDiamond(0x7D1f13Dd05E6b0673DC3D0BFa14d40A74Cfa3EF2);
    IPermit2 immutable PERMIT2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    constructor() ERC20('Energy ETH', 'eETH') {}


    function getPrice() public view returns(uint256) {
        return OZL.getEnergyPrice();
    }


    function issue(IPermit2.Permit2Buy memory buyOp_) external payable {
        uint256 toBuy = buyOp_.amount;
        if (toBuy == 0) revert Cant_be_zero();

        uint256 quote = (toBuy * getPrice()) / 10 ** 12;
        uint256 buyerBalance = buyOp_.token.balanceOf(msg.sender);

        if (buyerBalance < quote) revert Not_enough_funds(buyerBalance);

        (, uint256 fee) = LibHelpers.getFee(quote, OZL.getProtocolFee());
        
        buyOp_.amount = quote + fee; //check decimals

        _issue(buyOp_);

        // _mint(msg.sender, toBuy);

        // OZL.depositFeesInDeFi(fee, false);

        //---------


       //check why it failed
        
    }

    function _issue(IPermit2.Permit2Buy memory buyOp_) private {
        uint256 amount = buyOp_.amount;

        PERMIT2.permitTransferFrom(
            IPermit2.PermitTransferFrom({
                permitted: IPermit2.TokenPermissions({
                    token: buyOp_.token,
                    amount: amount
                }),
                nonce: buyOp_.nonce,
                deadline: buyOp_.deadline
            }),
            IPermit2.SignatureTransferDetails({
                to: address(this),
                requestedAmount: amount
            }),
            msg.sender,
            buyOp_.signature
        );
    }



    // function _depositFeesInDeFi(uint fee_, bool isRetry_) private { 
    //     /// @dev Into Curve's Tricrypto
    //     (uint tokenAmountIn, uint[3] memory amounts) = _calculateTokenAmountCurve(fee_);

    //     USDT.approve(address(tricrypto), tokenAmountIn);

    //     for (uint i=1; i <= 2; i++) {
    //         uint minAmount = LibHelpers.calculateSlippage(tokenAmountIn, OZL.getDefaultSlippage() * i);

    //         try tricrypto.add_liquidity(amounts, minAmount) {
    //             /// @dev Into Yearn's crvTricrypto
    //             crvTricrypto.approve(
    //                 address(yTriPool), crvTricrypto.balanceOf(address(this))
    //             );

    //             yTriPool.deposit(crvTricrypto.balanceOf(address(this)));

    //             /// @dev Internal fees accounting
    //             if (s.failedFees > 0) s.failedFees = 0;
    //             s.feesVault += fee_;
                
    //             break;
    //         } catch {
    //             if (i == 1) {
    //                 continue;
    //             } else {
    //                 if (!isRetry_) s.failedFees += fee_; 
    //             }
    //         }
    //     }
    // }






}

