// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { UC, uc } from "unchecked-counter/UC.sol";
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import "forge-std/Test.sol";
// import '../../contracts/facets/ozOracleFacet.sol';
// import '../../contracts/facets/ozExecutor2Facet.sol';
// import '../../contracts/facets/ozLoupeV2Facet.sol';
// import '../../contracts/facets/ozCutFacetV2.sol';
// import '../../contracts/EnergyETH.sol';
// import '../../contracts/testing-files/WtiFeed.sol';
// import '../../contracts/testing-files/EthFeed.sol';
// import '../../contracts/testing-files/GoldFeed.sol';
// import '../../contracts/InitUpgradeV2.sol';
// import '../../interfaces/ozIDiamond.sol';
import '../../libraries/PermitHash.sol';
import '../../libraries/LibHelpers.sol';
import '../../libraries/LibPermit2.sol';
import '../../interfaces/IPermit2.sol';
import './Setup.sol';

import "forge-std/console.sol";



contract EnergyETHTest is Test, Setup {

    using LibPermit2 for IERC20;


    function test_getPrice() public {
        uint price = eETH.getPrice();
        assertTrue(price > 0);
    }


    function test_issue(uint256 amount_) public {
        vm.assume(amount_ > 0);
        vm.assume(amount_ < 3);

        uint256 quote = (amount_ * OZL.getEnergyPrice()) / 10 ** 12;
        (, uint256 fee) = LibHelpers.getFee(quote, OZL.getProtocolFee());

        vm.startPrank(bob);
        USDT.approve(address(permit2), type(uint).max);

        IPermit2.TokenPermissions[] memory amounts = USDT.getTokenAmounts(fee, quote);

        IPermit2.PermitBatchTransferFrom memory permit = IPermit2.PermitBatchTransferFrom({
            permitted: amounts,
            nonce: _randomUint256(),
            deadline: block.timestamp
        });

        bytes memory sig = _signPermit(permit, address(eETH), bobKey);
  
        IPermit2.Permit2Buy memory buyOp = IPermit2.Permit2Buy({
            token: USDT,
            amount: amount_,
            nonce: permit.nonce,
            deadline: permit.deadline,
            signature: sig
        });

        //Pre-conditions
        uint256 balEnergyContr = USDT.balanceOf(address(eETH));
        assertTrue(balEnergyContr == 0);

        uint256 oldFees = OZL.getFeesVault();
        (, uint256 oldAUM) = OZL.getAUM();

        uint256 eETHbal = eETH.balanceOf(bob);
        assertTrue(eETHbal == 0);

        //Action
        eETH.issue(buyOp);
        vm.stopPrank();

        //Post-conditions
        balEnergyContr = USDT.balanceOf(address(eETH));
        assertTrue(balEnergyContr > 0);

        uint256 newFees = OZL.getFeesVault();
        assertTrue(newFees > oldFees);

        (, uint256 newAUM) = OZL.getAUM();
        assertTrue(newAUM > oldAUM);

        eETHbal = eETH.balanceOf(bob);
        assertTrue(eETHbal > 0);
    }



    /**
        *** HELPERS *****
     */

    // Generate a signature for a permit message of batch txs
    function _signPermit(
        IPermit2.PermitBatchTransferFrom memory permit,
        address spender,
        uint256 signerKey
    ) internal view returns (bytes memory sig)
    {
        (uint8 v, bytes32 r, bytes32 s) =
            vm.sign(signerKey, _getEIP712Hash(permit, spender));
        return abi.encodePacked(r, s, v);
    }


    // Compute the EIP712 hash of the permit batch object.
    function _getEIP712Hash(
        IPermit2.PermitBatchTransferFrom memory permit,
        address spender
    ) internal view returns (bytes32) 
    {
        uint256 length = permit.permitted.length; 
        bytes32[] memory tokenPermissions = new bytes32[](length);
        
        for (UC i = uc(0); i < uc(length); i = i + uc(1)) {
            uint256 ii = i.unwrap();
            tokenPermissions[ii] = keccak256(
                abi.encode(PermitHash._TOKEN_PERMISSIONS_TYPEHASH, permit.permitted[ii])
            );
        }

        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                permit2.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        PermitHash._PERMIT_BATCH_TRANSFER_FROM_TYPEHASH,
                        keccak256(abi.encodePacked(tokenPermissions)),
                        spender,
                        permit.nonce,
                        permit.deadline
                    )
                )
            )
        );
    }
}