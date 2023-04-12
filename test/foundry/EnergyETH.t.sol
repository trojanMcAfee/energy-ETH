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

    // uint256 bobKey;
    
    // ozOracleFacet private ozOracle;
    // ozExecutor2Facet private ozExecutor2;
    // ozLoupeV2Facet private ozLoupeV2;
    // ozCutFacetV2 private ozCutV2;

    // EnergyETH private eETH;

    // WtiFeed private wtiFeed;
    // EthFeed private ethFeed;
    // GoldFeed private goldFeed;

    // ozIDiamond private OZL;
    // InitUpgradeV2 private initUpgrade;

    // address private deployer = 0xe738696676571D9b74C81716E4aE797c2440d306;
    // address private volIndex = 0xbcD8bEA7831f392bb019ef3a672CC15866004536;
    // address private diamond = 0x7D1f13Dd05E6b0673DC3D0BFa14d40A74Cfa3EF2;

    //**** No use (Except in labels - remove ot) */
    // address crvTricrypto = 0x8e0B8c8BB9db49a46697F3a5Bb8A308e744821D2;
    // address yTricryptoPoolAddr = 0x239e14A19DFF93a17339DCC444f74406C17f8E67;
    // address chainlinkAggregatorAddr = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;
    // address ozLoupe = 0xd986Ac35f3aD549794DBc70F33084F746b58b534;
    // address revenueFacet = 0xD552211891bdBe3eA006343eF80d5aB283De601C;
    // IERC20 USDC = IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);
    // address alice = makeAddr('alice');
    // address ray = makeAddr('ray');

    // IERC20 USDT = IERC20(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9);

    // IPermit2 permit2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    // address bob;




    // function setUp() public {
    //     vm.createSelectFork(vm.rpcUrl('arbitrum'), 69254399); 

    //     (
    //         address[] memory nonRevFacets,
    //         address[] memory feeds
    //     ) = _createContracts();

    //     initUpgrade = new InitUpgradeV2();

    //     OZL = ozIDiamond(diamond);

    //     bytes memory data = abi.encodeWithSelector(
    //         initUpgrade.init.selector,
    //         feeds,
    //         nonRevFacets
    //     );

    //     //Creates FacetCut array
    //     ozIDiamond.FacetCut[] memory cuts = new ozIDiamond.FacetCut[](4);
    //     cuts[0] = _createCut(address(ozOracle), 0);
    //     cuts[1] = _createCut(address(ozExecutor2), 1); 
    //     cuts[2] = _createCut(address(ozLoupeV2), 2);
    //     cuts[3] = _createCut(address(ozCutV2), 3);

    //     vm.prank(deployer);
    //     OZL.diamondCut(cuts, address(initUpgrade), data);

    //     bobKey = _randomUint256();
    //     bob = vm.addr(bobKey);
        
    //     deal(address(USDT), bob, 5000 * 10 ** 6);

    //     _setLabels();
    // }

    //------------------------


    function test_getPrice() public {
        uint price = eETH.getPrice();
        assertTrue(price > 0);
    }

    function testFuzz_issue(uint256 amount_) public {
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

    // function test_getOracles() public {
    //     address[] memory oracles = OZL.getOracles();
    //     assertTrue(address(ozOracle) == oracles[0]);
    // }

    // function test_getOracleIdByAddress() public {
    //     bytes32 oracleID = OZL.getOracleIdByAddress(address(ozOracle));
    //     bytes32 calcID = keccak256(abi.encodePacked(address(ozOracle)));
    //     assertTrue(oracleID == calcID);
    // }

    // function test_getOracleAddressById() public {
    //     bytes32 id = keccak256(abi.encodePacked(address(ozOracle)));
    //     address oracle = OZL.getOracleAddressById(id);
    //     assertTrue(oracle == address(ozOracle));
    // }





    //------ Helpers -----

    function invariant_myTest() public {
        assertTrue(true);
    }


    // function _createCut(
    //     address contractAddr_, 
    //     uint8 id_
    // ) private view returns(ozIDiamond.FacetCut memory cut) { 
    //     uint256 length;
    //     if (id_ == 2) {
    //         length = 4;
    //     } else if (id_ == 3) {
    //         length = 2;
    //     } else {
    //         length = 1;
    //     }
        

    //     bytes4[] memory selectors = new bytes4[](length);

    //     if (id_ == 0) selectors[0] = ozOracle.getEnergyPrice.selector;
    //     if (id_ == 1) selectors[0] = ozExecutor2.depositFeesInDeFi.selector;
    //     if (id_ == 2) {
    //         selectors[0] = ozLoupeV2.getFeesVault.selector;
    //         selectors[1] = ozLoupeV2.getOracles.selector;
    //         selectors[2] = ozLoupeV2.getOracleIdByAddress.selector;
    //         selectors[3] = ozLoupeV2.getOracleAddressById.selector;
    //     }
    //     if (id_ == 3) {
    //         selectors[0] = ozCutV2.addOracle.selector;
    //         selectors[1] = ozCutV2.removeOracle.selector;
    //     }

    //     cut = ozIDiamond.FacetCut({
    //         facetAddress: contractAddr_,
    //         action: ozIDiamond.FacetCutAction.Add,
    //         functionSelectors: selectors
    //     });
    // }


    // function _createContracts() private returns(
    //     address[] memory,
    //     address[] memory
    // ) {
    //     ethFeed = new EthFeed();
    //     goldFeed = new GoldFeed();
    //     wtiFeed = new WtiFeed();

    //     ozOracle = new ozOracleFacet(); 
    //     eETH = new EnergyETH();
    //     ozExecutor2 = new ozExecutor2Facet();
    //     ozLoupeV2 = new ozLoupeV2Facet();
    //     ozCutV2 = new ozCutFacetV2();

    //     address[] memory nonRevFacets = new address[](2);
    //     nonRevFacets[0] = address(ozOracle);
    //     nonRevFacets[1] = address(ozLoupeV2);

    //     address[] memory feeds = new address[](4);
    //     feeds[0] = address(wtiFeed);
    //     feeds[1] = volIndex;
    //     feeds[2] = address(ethFeed);
    //     feeds[3] = address(goldFeed); 

    //     return (nonRevFacets, feeds);
    // }


    // function _setLabels() private {
    //     vm.label(address(ozOracle), 'ozOracle');
    //     vm.label(address(initUpgrade), 'initUpgrade');
    //     vm.label(address(wtiFeed), 'wtiFeed');
    //     vm.label(address(ethFeed), 'ethFeed');
    //     vm.label(address(goldFeed), 'goldFeed');
    //     vm.label(address(OZL), 'OZL');
    //     vm.label(deployer, 'deployer2');
    //     vm.label(volIndex, 'volIndex');
    //     vm.label(crvTricrypto, 'crvTricrypto');
    //     vm.label(yTricryptoPoolAddr, 'yTricryptoPool');
    //     vm.label(chainlinkAggregatorAddr, 'chainlinkAggregator');
    //     // vm.label(ozLoupe, 'ozLoupe');
    //     vm.label(revenueFacet, 'revenueFacet');
    //     vm.label(address(eETH), 'eETH');
    //     vm.label(address(USDT), 'USDT');
    //     vm.label(address(permit2), 'permit2');
    //     vm.label(bob, 'bob');
    //     vm.label(alice, 'alice');
    //     vm.label(ray, 'ray');
    //     vm.label(address(ozExecutor2), 'ozExecutor2');
    //     vm.label(address(ozLoupeV2), 'ozLoupeV2');
    //     vm.label(address(ozCutFacetV2), 'ozCutFacetV2');
    // }

   
    // function _randomUint256() internal view returns (uint256) {
    //     return block.difficulty;
    // }


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