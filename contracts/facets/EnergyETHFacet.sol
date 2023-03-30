// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '../../interfaces/ozIDiamond.sol';
// import './ozOracleFacet.sol';
import "forge-std/console.sol";
// import 'hardhat/console.sol';


error Cant_be_zero();
error Not_enough_funds(uint256 buyerBalance);
error Cant_approve(uint256 amount);
error Cant_transfer(uint256 amount);


contract EnergyETHFacet is ERC20 {

    IERC20 USDC = IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);
    address immutable wethAdrr = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    ozIDiamond OZL = ozIDiamond(0x7D1f13Dd05E6b0673DC3D0BFa14d40A74Cfa3EF2);

    constructor() ERC20('Energy ETH', 'eETH') {}


    function getPrice() public view returns(uint256) {
        return OZL.getEnergyPrice();
    }

    
    function issue(address user_, uint256 amount_) external {
        if (amount_ == 0) revert Cant_be_zero();

        uint256 quote = (amount_ * getPrice()) / 10 ** 12;
        uint256 buyerBalance = USDC.balanceOf(msg.sender);

        if (buyerBalance < quote) revert Not_enough_funds(buyerBalance);

        bool success = USDC.transferFrom(msg.sender, address(this), quote);
        if (!success) revert Cant_transfer(quote);
        //--------

        // ISwapRouter.ExactInputSingleParams memory params =
        //     ISwapRouter.ExactInputSingleParams({
        //         tokenIn: address(USDC),
        //         tokenOut: wethAdrr, 
        //         fee: eMode.poolFee,
        //         recipient: address(this),
        //         deadline: block.timestamp,
        //         amountIn: USDC.balanceOf(address(this)),
        //         amountOutMinimum: _calculateMinOut(eMode, i, balanceWETH, slippage_), 
        //         sqrtPriceLimitX96: 0
        //     });
        

    }


    function _depositInDeFi() private {



    }


}

