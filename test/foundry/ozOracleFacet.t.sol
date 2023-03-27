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

    uint256 arbFork;
    
    ozOracleFacet private ozOracle;
    EnergyETHFacet private energyFacet;
    InitUpgradeV2 private initUpgrade;
    WtiFeed private wtiFeed;
    EthFeed private ethFeed;
    GoldFeed private goldFeed;
    ozIDiamond private OZL;

    address private deployer = 0xe738696676571D9b74C81716E4aE797c2440d306;
    address private volIndex = 0xbcD8bEA7831f392bb019ef3a672CC15866004536;
    address private diamond = 0x7D1f13Dd05E6b0673DC3D0BFa14d40A74Cfa3EF2;

    address bob = makeAddr('bob');


    // struct FuzzSelector {
    //     address addr;
    //     bytes4[] selectors;
    // }


    function setUp() public {
        string memory ARB_RPC = vm.envString('ARBITRUM');
        vm.createSelectFork(ARB_RPC, 69254399);

        //Deploys feeds
        ethFeed = new EthFeed();
        goldFeed = new GoldFeed();
        wtiFeed = new WtiFeed();

        ozOracle = new ozOracleFacet(); 
        energyFacet = new EnergyETHFacet();
        initUpgrade = new InitUpgradeV2();

        OZL = ozIDiamond(diamond);

        address[] memory facets = new address[](2);
        facets[0] = address(ozOracle);
        facets[1] = address(energyFacet);

        address[] memory feeds = new address[](4);
        feeds[0] = address(wtiFeed);
        feeds[1] = volIndex;
        feeds[2] = address(ethFeed);
        feeds[3] = address(goldFeed); 

        bytes memory data = abi.encodeWithSelector(
            initUpgrade.init.selector,
            feeds,
            facets
        );

        //FacetCut for ozOracle
        bytes4[] memory selecOracle = new bytes4[](1);
        selecOracle[0] = ozOracle.getLastPrice.selector;

        ozIDiamond.FacetCut memory cut = ozIDiamond.FacetCut({
            facetAddress: address(ozOracle),
            action: ozIDiamond.FacetCutAction.Add,
            functionSelectors: selecOracle
        });

        //FacetCut for EnergyFacet
        bytes4[] memory selecEnergy = new bytes4[](1);
        selecEnergy[0] = energyFacet.getEnergyPrice.selector;

        ozIDiamond.FacetCut memory cut2 = ozIDiamond.FacetCut({
            facetAddress: address(energyFacet),
            action: ozIDiamond.FacetCutAction.Add,
            functionSelectors: selecEnergy
        });

        //FacetCut array
        ozIDiamond.FacetCut[] memory cuts = new ozIDiamond.FacetCut[](2);
        cuts[0] = cut;
        cuts[1] = cut2;

        vm.prank(deployer);
        OZL.diamondCut(cuts, address(initUpgrade), data);

        //-----------------
        // targetContract(address(ozOracle));
        // bytes4[] memory selecs = new bytes4[](1);
        // selecs[0] = ozOracle.getLastPrice.selector;

        // FuzzSelector memory selectors = FuzzSelector({
        //     addr: address(ozOracle),
        //     selectors: selecs
        // });

        // targetSelector(selectors);
    }

    //---------

    function test_getLastPrice() public {
        uint price = OZL.getLastPrice();
        assertTrue(price > 0);
    }

    function test_getEnergyPrice() public {
        uint price = OZL.getEnergyPrice();
        assertTrue(price > 0);
    }

    // function test_getHello() public {
    //     uint num = wtiFeed.getNum();
    //     assertTrue(num == 3);
    // }


    // function invariant_myTest() public {
    //     uint price = OZL.getLastPrice();
    //     assertTrue(price > 0);
    // }

}