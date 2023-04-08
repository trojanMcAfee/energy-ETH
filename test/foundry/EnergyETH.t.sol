// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import "forge-std/Test.sol";
import "forge-std/console.sol";
import '../../contracts/facets/ozOracleFacet.sol';
import '../../contracts/facets/ozExecutor2Facet.sol';
import '../../contracts/EnergyETH.sol';
import '../../contracts/testing-files/WtiFeed.sol';
import '../../contracts/testing-files/EthFeed.sol';
import '../../contracts/testing-files/GoldFeed.sol';
// import '../../contracts/ozDiamond.sol';
import '../../contracts/InitUpgradeV2.sol';
import '../../interfaces/ozIDiamond.sol';
import '../../libraries/PermitHash.sol';
import '../../libraries/LibHelpers.sol';
import '../../interfaces/IPermit2.sol';

import { UC, uc } from "unchecked-counter/UC.sol";



contract EnergyETHTest is Test {

    using PermitHash for ISignatureTransfer.PermitBatchTransferFrom;

    bytes32 constant TOKEN_PERMISSIONS_TYPEHASH =
        keccak256("TokenPermissions(address token,uint256 amount)");
    bytes32 constant PERMIT_TRANSFER_FROM_TYPEHASH = keccak256(
        "PermitTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline)TokenPermissions(address token,uint256 amount)"
    );
    bytes32 public constant _PERMIT_BATCH_TRANSFER_FROM_TYPEHASH = keccak256(
        "PermitBatchTransferFrom(TokenPermissions[] permitted,address spender,uint256 nonce,uint256 deadline)TokenPermissions(address token,uint256 amount)"
    );
    bytes32 public constant _PERMIT_BATCH_TYPEHASH = keccak256(
        "PermitBatch(PermitDetails[] details,address spender,uint256 sigDeadline)PermitDetails(address token,uint160 amount,uint48 expiration,uint48 nonce)"
    );

    bytes32 public constant _PERMIT_TRANSFER_FROM_TYPEHASH = keccak256(
        "PermitTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline)TokenPermissions(address token,uint256 amount)"
    );

    uint256 bobKey;
    
    ozOracleFacet private ozOracle;
    ozExecutor2Facet private ozExecutor2;
    EnergyETH private energyFacet;
    InitUpgradeV2 private initUpgrade;
    WtiFeed private wtiFeed;
    EthFeed private ethFeed;
    GoldFeed private goldFeed;
    ozIDiamond private OZL;

    address private deployer = 0xe738696676571D9b74C81716E4aE797c2440d306;
    address private volIndex = 0xbcD8bEA7831f392bb019ef3a672CC15866004536;
    address private diamond = 0x7D1f13Dd05E6b0673DC3D0BFa14d40A74Cfa3EF2;

    address crvTricrypto = 0x8e0B8c8BB9db49a46697F3a5Bb8A308e744821D2;
    address yTricryptoPoolAddr = 0x239e14A19DFF93a17339DCC444f74406C17f8E67;
    address chainlinkAggregatorAddr = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;

    address ozLoupe = 0xd986Ac35f3aD549794DBc70F33084F746b58b534;
    address revenueFacet = 0xD552211891bdBe3eA006343eF80d5aB283De601C;

    IERC20 USDT = IERC20(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9);
    IERC20 USDC = IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);

    IPermit2 permit2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    address bob;
    address alice = makeAddr('alice');
    address ray = makeAddr('ray');


    // struct FuzzSelector {
    //     address addr;
    //     bytes4[] selectors;
    // }


    function setUp() public {
        vm.createSelectFork(vm.rpcUrl('arbitrum'), 69254399); //69254399

        //----------

        (
            address[] memory facets, //not all contracts are facets
            address[] memory feeds
        ) = _createContracts();

        initUpgrade = new InitUpgradeV2();

        OZL = ozIDiamond(diamond);

        bytes memory data = abi.encodeWithSelector(
            initUpgrade.init.selector,
            feeds,
            facets
        );

        //Creates FacetCut array
        ozIDiamond.FacetCut[] memory cuts = new ozIDiamond.FacetCut[](2);
        cuts[0] = _createCut(address(ozOracle), 0);
        cuts[1] = _createCut(address(ozExecutor2), 1);

        vm.prank(deployer);
        OZL.diamondCut(cuts, address(initUpgrade), data);

        // energyFacet = new EnergyETH();

        //--------

        bobKey = _randomUint256();
        bob = vm.addr(bobKey);
        console.log('bob: ', bob);
        
        deal(address(USDT), bob, 5000 * 10 ** 6);

        //-----------------
        // targetContract(address(ozOracle));
        // bytes4[] memory selecs = new bytes4[](1);
        // selecs[0] = ozOracle.getLastPrice.selector;

        // FuzzSelector memory selectors = FuzzSelector({
        //     addr: address(ozOracle),
        //     selectors: selecs
        // });

        // targetSelector(selectors);

        _setLabels();

        //---------

    }



    function test_getPrice() public {
        uint price = energyFacet.getPrice();
        assertTrue(price > 0);
    }

    function testFuzz_issue(uint256 amount_) public {
        vm.assume(amount_ > 0);
        vm.assume(amount_ < 3);

        uint256 quote = (amount_ * OZL.getEnergyPrice()) / 10 ** 12;
        (, uint256 fee) = LibHelpers.getFee(quote, OZL.getProtocolFee());

        vm.startPrank(bob);
        USDT.approve(address(permit2), type(uint).max);

        
        //--------------
        // IPermit2.PermitTransferFrom memory permit = IPermit2.PermitTransferFrom({
        //     permitted: IPermit2.TokenPermissions({
        //         token: USDT,
        //         amount: quote + fee
        //     }),
        //     nonce: _randomUint256(),
        //     deadline: block.timestamp
        // });
        //-------------
        IPermit2.TokenPermissions memory feeStruct = IPermit2.TokenPermissions({
            token: USDT,
            amount: fee
        });

        IPermit2.TokenPermissions memory quoteStruct = IPermit2.TokenPermissions({
            token: USDT,
            amount: quote
        });

        console.log('fee in test: ', fee);
        console.log('quote in test: ', quote);

        IPermit2.TokenPermissions[] memory amounts = new IPermit2.TokenPermissions[](2);
        amounts[0] = feeStruct;
        amounts[1] = quoteStruct;

        IPermit2.PermitBatchTransferFrom memory permit = IPermit2.PermitBatchTransferFrom({
            permitted: amounts,
            nonce: _randomUint256(),
            deadline: block.timestamp
        });

        //---------------

        bytes memory sig = _signPermit(permit, address(energyFacet), bobKey);
  
        IPermit2.Permit2Buy memory buyOp = IPermit2.Permit2Buy({
            token: USDT,
            amount: amount_,
            nonce: permit.nonce,
            deadline: permit.deadline,
            signature: sig
        });

        energyFacet.issue(buyOp);

        vm.stopPrank();

        uint bal = USDT.balanceOf(address(energyFacet));
        assertTrue(bal > 0);
    }





    //------ Helpers -----

    function invariant_myTest() public {
        assertTrue(true);
    }


    function _createCut(
        address contractAddr_, 
        uint8 id_
    ) private view returns(ozIDiamond.FacetCut memory cut) {
        bytes4[] memory selectors = new bytes4[](1);
        if (id_ == 0) selectors[0] = ozOracle.getEnergyPrice.selector;
        if (id_ == 1) selectors[0] = ozExecutor2.depositFeesInDeFi.selector;

        cut = ozIDiamond.FacetCut({
            facetAddress: contractAddr_,
            action: ozIDiamond.FacetCutAction.Add,
            functionSelectors: selectors
        });
    }


    function _createContracts() private returns(
        address[] memory,
        address[] memory
    ) {
        ethFeed = new EthFeed();
        goldFeed = new GoldFeed();
        wtiFeed = new WtiFeed();

        ozOracle = new ozOracleFacet(); 
        energyFacet = new EnergyETH();
        ozExecutor2 = new ozExecutor2Facet();

        address[] memory facets = new address[](3);
        facets[0] = address(ozOracle);
        facets[1] = address(energyFacet);
        facets[2] = address(ozExecutor2);

        address[] memory feeds = new address[](4);
        feeds[0] = address(wtiFeed);
        feeds[1] = volIndex;
        feeds[2] = address(ethFeed);
        feeds[3] = address(goldFeed); 

        return (facets, feeds);
    }


    function _setLabels() private {
        vm.label(address(ozOracle), 'ozOracle');
        vm.label(address(energyFacet), 'energyFacet');
        vm.label(address(initUpgrade), 'initUpgrade');
        vm.label(address(wtiFeed), 'wtiFeed');
        vm.label(address(ethFeed), 'ethFeed');
        vm.label(address(goldFeed), 'goldFeed');
        vm.label(address(OZL), 'OZL');
        vm.label(deployer, 'deployer2');
        vm.label(volIndex, 'volIndex');
        vm.label(crvTricrypto, 'crvTricrypto');
        vm.label(yTricryptoPoolAddr, 'yTricryptoPool');
        vm.label(chainlinkAggregatorAddr, 'chainlinkAggregator');
        vm.label(ozLoupe, 'ozLoupe');
        vm.label(revenueFacet, 'revenueFacet');
        vm.label(address(energyFacet), 'energyFacet');
        vm.label(address(USDT), 'USDT');
        vm.label(address(permit2), 'permit2');
        vm.label(bob, 'bob');
        vm.label(alice, 'alice');
        vm.label(ray, 'ray');
        vm.label(address(ozExecutor2), 'ozExecutor2');
    }


    //---------
    function _randomBytes32() internal view returns (bytes32) {
        return keccak256(abi.encode(
            tx.origin,
            block.number,
            block.timestamp,
            block.coinbase,
            address(this).codehash,
            gasleft()
        ));
    }

    function _randomUint256() internal view returns (uint256) {
        return uint256(_randomBytes32());
    }

    //-----------



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

    // Compute the EIP712 hash of the permit object.
    function _getEIP712Hash(
        IPermit2.PermitBatchTransferFrom memory permit,
        address spender
    ) internal view returns (bytes32) 
    {
        uint256 length = permit.permitted.length; 
        bytes32[] memory tokenPermissions = new bytes32[](length);
        
        for (UC i = uc(0); i < uc(length); i = i + uc(1)) {
            uint256 ii = i.unwrap();
            tokenPermissions[ii] = keccak256(abi.encode(TOKEN_PERMISSIONS_TYPEHASH, permit.permitted[ii]));
        }

        bytes32 msgHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                permit2.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        _PERMIT_BATCH_TRANSFER_FROM_TYPEHASH,
                        keccak256(abi.encodePacked(tokenPermissions)),
                        spender,
                        permit.nonce,
                        permit.deadline
                    )
                )
            )
        );
        return msgHash;
    }

    

}