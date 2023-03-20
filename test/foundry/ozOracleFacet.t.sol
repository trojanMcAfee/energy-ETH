// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


// import 'ds-test/test.sol';
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import '../../contracts/ozOracleFacet.sol';
import '../../contracts/testing-files/WtiFeed.sol';
import '../../contracts/testing-files/EthFeed.sol';
import '../../contracts/testing-files/GoldFeed.sol';
// import '../../contracts/ozDiamond.sol';
import '../../contracts/InitUpgradeV2.sol';
import '../../interfaces/ozIDiamond.sol';


// contract ozOracleFacetTest is Test {
    
//     ozOracleFacet private ozOracle;
//     InitUpgradeV2 private init;
//     WtiFeed private wtiFeed;
//     EthFeed private ethFeed;
//     GoldFeed private goldFeed;
//     ozIDiamond private OZL;

//     address private deployer = 0xe738696676571D9b74C81716E4aE797c2440d306;
//     address private volIndex = 0xbcD8bEA7831f392bb019ef3a672CC15866004536;
//     address private diamond = 0x7D1f13Dd05E6b0673DC3D0BFa14d40A74Cfa3EF2;


//     // struct FacetCut {
//     //     address facetAddress;
//     //     FacetCutAction action;
//     //     bytes4[] functionSelectors;
//     // }

//     // enum FacetCutAction {Add, Replace, Remove}

//     // function diamondCut(
//     //     FacetCut[] calldata _diamondCut,
//     //     address _init,
//     //     bytes calldata _calldata
//     // ) external;

      

//     function setUp() public {
//         ethFeed = new EthFeed();
//         goldFeed = new GoldFeed();
//         wtiFeed = new WtiFeed();

//         vm.label(address(ethFeed), 'ethFeed');
//         vm.label(address(goldFeed), 'goldFeed'); //label them

//         address[] memory feeds = new address[](4);
//         feeds[0] = address(wtiFeed);
//         feeds[1] = volIndex;
//         feeds[2] = address(ethFeed);
//         feeds[3] = address(goldFeed);    

//         ozOracle = new ozOracleFacet(); 
//         init = new InitUpgradeV2();
//         OZL = ozIDiamond(diamond);

//         bytes4[] memory selectors = new bytes4[](1);
//         selectors[0] = bytes4(ozOracle.getLastPrice.selector);

//         bytes memory data = abi.encodeWithSelector(
//             init.init.selector,
//             feeds
//         );

//         ozIDiamond.FacetCut memory cut = ozIDiamond.FacetCut({
//             facetAddress: address(ozOracle),
//             action: ozIDiamond.FacetCutAction.Add,
//             functionSelectors: selectors
//         });

//         ozIDiamond.FacetCut[] memory cuts = new ozIDiamond.FacetCut[](1);
//         cuts[0] = cut;

//         vm.prank(deployer);
//         OZL.diamondCut(cuts, address(init), data);
//     }

//     function testLastPrice() public {
//         uint price = OZL.getLastPrice();
//         assertTrue(price > 0);
//     }

// }


// contract ozOracleFacetTest is Test {

//     ozOracleFacet private ozOracle;
//     WtiFeed private wtiFeed;
//     EthFeed private ethFeed;
//     GoldFeed private goldFeed;

//     address volAddress = 0xbcD8bEA7831f392bb019ef3a672CC15866004536;

//     function setUp() public {
//         wtiFeed = new WtiFeed();
//         ethFeed = new EthFeed();
//         goldFeed = new GoldFeed();

//         ozOracle = new ozOracleFacet(
//             address(wtiFeed),
//             volAddress,
//             address(ethFeed),
//             address(goldFeed)
//         );

//         vm.label(address(wtiFeed), 'wtiFeed');
//         vm.label(address(ethFeed), 'ethFeed');
//         vm.label(address(goldFeed), 'goldFeed');
//         vm.label(volAddress, 'volFeed');
//         vm.label(address(ozOracle), 'eETH');
//     }

    // function testLastPrice() public {
    //     uint price = ozOracle.getLastPrice();
    //     assertTrue(price > 0);
    // }

//     // function invariant_neverFails() public pure {
//     //     bool success = true;
//     //     require(success);
//     // }

// }