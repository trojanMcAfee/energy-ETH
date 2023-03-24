// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


// import 'ds-test/test.sol';
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import '@openzeppelin/contracts/utils/Address.sol';
import "forge-std/Test.sol";
import "forge-std/console.sol";
import '../../contracts/facets/ozOracleFacet.sol';
import '../../contracts/facets/EnergyETHFacet.sol';
import '../../contracts/testing-files/WtiFeed.sol';
import '../../contracts/testing-files/EthFeed.sol';
import '../../contracts/testing-files/GoldFeed.sol';
// import '../../contracts/ozDiamond.sol';
import '../../contracts/InitUpgradeV2.sol';
import '../../interfaces/ozIDiamond.sol';


contract ozOracleFacetTest is Test {
    
    ozOracleFacet private ozOracle;
    EnergyETHFacet private energyFacet;
    InitUpgradeV2 private init;
    WtiFeed private wtiFeed;
    EthFeed private ethFeed;
    GoldFeed private goldFeed;
    ozIDiamond private OZL;

    address private deployer = 0xe738696676571D9b74C81716E4aE797c2440d306;
    address private volIndex = 0xbcD8bEA7831f392bb019ef3a672CC15866004536;
    address private diamond = 0x7D1f13Dd05E6b0673DC3D0BFa14d40A74Cfa3EF2;

    address bob = makeAddr('bob');

      
    function setUp() public {

        //Deploys feeds
        ethFeed = new EthFeed();
        goldFeed = new GoldFeed();
        wtiFeed = new WtiFeed();

        vm.label(address(ethFeed), 'ethFeed');
        vm.label(address(goldFeed), 'goldFeed');
        vm.label(address(wtiFeed), 'wtiFeed');
        //---------   

        ozOracle = new ozOracleFacet(); 
        energyFacet = new EnergyETHFacet();
        init = new InitUpgradeV2();

        OZL = ozIDiamond(diamond);

        vm.label(address(ozOracle), 'oracle');
        vm.label(address(init), 'init');
        vm.label(address(OZL), 'ozDiamond');
        vm.label(address(energyFacet), 'energyFacet');

        address[] memory facets = new address[](2);
        facets[0] = address(ozOracle);
        facets[1] = address(energyFacet);

        address[] memory feeds = new address[](4);
        feeds[0] = address(wtiFeed);
        feeds[1] = volIndex;
        feeds[2] = address(ethFeed);
        feeds[3] = address(goldFeed); 

        bytes memory data = abi.encodeWithSelector(
            init.init.selector,
            feeds,
            facets
        );

        bytes4[] memory selecOracle = new bytes4[](1);
        selecOracle[0] = bytes4(ozOracle.getLastPrice.selector);

        ozIDiamond.FacetCut memory cut = ozIDiamond.FacetCut({
            facetAddress: address(ozOracle),
            action: ozIDiamond.FacetCutAction.Add,
            functionSelectors: selecOracle
        });

        ozIDiamond.FacetCut[] memory cuts = new ozIDiamond.FacetCut[](2);
        cuts[0] = cut;

        bytes4[] memory selecEnergy = new bytes4[](1);
        selecEnergy[0] = bytes4(energyFacet.getEnergyPrice.selector);

        cut = ozIDiamond.FacetCut({
            facetAddress: address(energyFacet),
            action: ozIDiamond.FacetCutAction.Add,
            functionSelectors: selecEnergy
        });
        cuts[1] = cut;

        vm.prank(deployer);
        OZL.diamondCut(cuts, address(init), data);
    }

    //---------
    function test_getLastPrice() public {
        uint price = OZL.getLastPrice();
        assertTrue(price > 0);
    }

    function test_getEnergyPrice() public {
        // vm.prank(bob);

        uint price = OZL.getEnergyPrice();

        // bytes memory data = abi.encodeWithSignature('getEnergyPrice');
        // data = Address.functionCall(address(OZL), data);
        // uint256 price = abi.decode(data, (uint256));
        // vm.stopPrank();

        assertTrue(price > 0);
    }

}