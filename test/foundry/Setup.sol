// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import '../../contracts/InitUpgradeV2.sol';
import '../../interfaces/ozIDiamond.sol';
import '../../interfaces/ArbSys.sol';
import '../../contracts/facets/ozOracleFacet.sol';
import '../../contracts/facets/ozExecutor2Facet.sol';
import '../../contracts/facets/ozLoupeV2Facet.sol';
import '../../contracts/facets/ozCutFacetV2.sol';
import '../../contracts/EnergyETH.sol';
import '../../contracts/testing-files/WtiFeed.sol';
import '../../contracts/testing-files/EthFeed.sol';
import '../../contracts/testing-files/GoldFeed.sol';
import '../../contracts/testing-files/DummyUniPool.sol';
import './dummy-files/NewOracle.sol';

import "forge-std/Test.sol";




contract Setup is Test {

    uint256 bobKey;

    address bob;

    ozOracleFacet internal ozOracle;
    ozExecutor2Facet internal ozExecutor2;
    ozLoupeV2Facet internal ozLoupeV2;
    ozCutFacetV2 internal ozCutV2;

    ozIDiamond internal OZL;
    InitUpgradeV2 internal initUpgrade;
    DummyUniPool internal dummyUniPool;

    EnergyETH internal eETH;

    WtiFeed internal wtiFeed;
    EthFeed internal ethFeed;
    GoldFeed internal goldFeed;

    NewOracle internal newOracle;

    address internal deployer = 0xe738696676571D9b74C81716E4aE797c2440d306;
    address internal volIndex = 0xbcD8bEA7831f392bb019ef3a672CC15866004536;
    address internal diamond = 0x7D1f13Dd05E6b0673DC3D0BFa14d40A74Cfa3EF2;
    address internal deadAddr = 0x000000000000000000000000000000000000dEaD;
    address internal ethUsdcPool = 0xC31E54c7a869B9FcBEcc14363CF510d1c41fa443;

    IERC20 USDT = IERC20(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9);

    IPermit2 permit2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    uint256 fork700;

    bytes notOwner = bytes('LibDiamond: Must be contract owner');

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl('arbitrum'), 69254399);
        fork700 = vm.createFork(vm.rpcUrl('arbitrum'), 69254700);
        _runSetup();
    }

    function _runSetup() internal {
        (
            address[] memory nonRevFacets,
            address[] memory feeds
        ) = _createContracts();

        initUpgrade = new InitUpgradeV2();
        dummyUniPool = new DummyUniPool();

        OZL = ozIDiamond(diamond);

        address[] memory otherVars = new address[](1);
        otherVars[0] = block.number == 69254700 ? address(dummyUniPool) : ethUsdcPool;

        bytes memory data = abi.encodeWithSelector(
            initUpgrade.init.selector,
            feeds,
            nonRevFacets,
            otherVars
        );

        //Creates FacetCut array
        ozIDiamond.FacetCut[] memory cuts = new ozIDiamond.FacetCut[](4);
        cuts[0] = _createCut(address(ozOracle), 0);
        cuts[1] = _createCut(address(ozExecutor2), 1); 
        cuts[2] = _createCut(address(ozLoupeV2), 2);
        cuts[3] = _createCut(address(ozCutV2), 3);

        vm.prank(deployer);
        OZL.diamondCut(cuts, address(initUpgrade), data);

        bobKey = _randomUint256();
        bob = vm.addr(bobKey);
        
        deal(address(USDT), bob, 5000 * 10 ** 6);

        _setLabels();
    }



    function _createContracts() private returns(
        address[] memory,
        address[] memory
    ) {
        //Price feeds
        ethFeed = new EthFeed();
        goldFeed = new GoldFeed();
        wtiFeed = new WtiFeed();

        //Facets and contracts
        ozOracle = new ozOracleFacet(); 
        eETH = new EnergyETH();
        ozExecutor2 = new ozExecutor2Facet();
        ozLoupeV2 = new ozLoupeV2Facet();
        ozCutV2 = new ozCutFacetV2();

        //Test contracts
        newOracle = new NewOracle();

        address[] memory nonRevFacets = new address[](2);
        nonRevFacets[0] = address(ozOracle);
        nonRevFacets[1] = address(ozLoupeV2);

        address[] memory feeds = new address[](4);
        feeds[0] = address(wtiFeed);
        feeds[1] = volIndex;
        feeds[2] = address(ethFeed);
        feeds[3] = address(goldFeed); 

        return (nonRevFacets, feeds);
    }



    function _createCut(
        address contractAddr_, 
        uint8 id_
    ) internal view returns(ozIDiamond.FacetCut memory cut) { 
        uint256 length;
        if (id_ == 0) {
            length = 9;
        } else if (id_ == 2) {
            length = 4;
        } else if (id_ == 3) {
            length = 2;
        } else {
            length = 1;
        }
        

        bytes4[] memory selectors = new bytes4[](length);

        if (id_ == 0) {
            selectors[0] = ozOracle.getEnergyPrice.selector;
            selectors[1] = ozOracle.getVolatilityIndex.selector;
            selectors[2] = ozOracle.changeVolatilityIndex.selector;
            selectors[3] = ozOracle.addFeed.selector;
            selectors[4] = ozOracle.removeFeed.selector;
            selectors[5] = ozOracle.getPriceFeeds.selector;
            selectors[6] = ozOracle.getTwapEth.selector;
            selectors[7] = ozOracle.changeUniPool.selector;
            selectors[8] = ozOracle.getUniPool.selector;
        }
        if (id_ == 1) selectors[0] = ozExecutor2.depositFeesInDeFi.selector;
        if (id_ == 2) {
            selectors[0] = ozLoupeV2.getFeesVault.selector;
            selectors[1] = ozLoupeV2.getOracles.selector;
            selectors[2] = ozLoupeV2.getOracleIdByAddress.selector;
            selectors[3] = ozLoupeV2.getOracleAddressById.selector;
        }
        if (id_ == 3) {
            selectors[0] = ozCutV2.addOracle.selector;
            selectors[1] = ozCutV2.removeOracle.selector;
        }
        if (id_ == 4) selectors[0] = newOracle.getVolatilityIndex.selector;

        cut = ozIDiamond.FacetCut({
            facetAddress: contractAddr_,
            action: id_ != 4 ? ozIDiamond.FacetCutAction.Add : ozIDiamond.FacetCutAction.Replace,
            functionSelectors: selectors
        });
    }


    function _randomUint256() internal view returns (uint256) {
        return block.difficulty;
    }



    function _setLabels() private {
        vm.label(address(ozOracle), 'ozOracle');
        vm.label(address(initUpgrade), 'initUpgrade');
        vm.label(address(wtiFeed), 'wtiFeed');
        vm.label(address(ethFeed), 'ethFeed');
        vm.label(address(goldFeed), 'goldFeed');
        vm.label(address(OZL), 'OZL');
        vm.label(deployer, 'deployer2');
        vm.label(volIndex, 'volIndex');
        vm.label(address(eETH), 'eETH');
        vm.label(address(USDT), 'USDT');
        vm.label(address(permit2), 'permit2');
        vm.label(bob, 'bob');
        vm.label(address(ozExecutor2), 'ozExecutor2');
        vm.label(address(ozLoupeV2), 'ozLoupeV2');
        vm.label(address(ozCutV2), 'ozCutFacetV2');
        vm.label(address(newOracle), 'newOracle');
        vm.label(ethUsdcPool, 'ethUsdcPool');
        vm.label(address(dummyUniPool), 'dummyUniPool');
    }


}