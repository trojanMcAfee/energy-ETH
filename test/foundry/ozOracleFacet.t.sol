// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


// import 'ds-test/test.sol';
import "forge-std/Test.sol";
import "forge-std/console.sol";
import '../../contracts/ozOracleFacet.sol';
import '../../contracts/testing-files/WtiFeed.sol';
import '../../contracts/testing-files/EthFeed.sol';
import '../../contracts/testing-files/GoldFeed.sol';
import '../../contracts/ozDiamond.sol';
import './InitUpgradeV2.sol';


contract ozOracleFacetTest is Test {
    
    ozOracleFacet private ozOracle;
    ozDiamond private diamond;
    InitUpgradeV2 private init;
    WtiFeed private wtiFeed;
    EthFeed private ethFeed;
    GoldFeed private goldFeed;

    address private deployer = 0xe738696676571D9b74C81716E4aE797c2440d306;

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    enum FacetCutAction {Add, Replace, Remove}

    // function diamondCut(
    //     FacetCut[] calldata _diamondCut,
    //     address _init,
    //     bytes calldata _calldata
    // ) external;

        // s.wtiFeed = AggregatorV3Interface(feeds_[0]);
        // s.volatilityFeed = AggregatorV3Interface(feeds_[1]);
        // s.ethFeed = AggregatorV3Interface(feeds_[2]);
        // s.goldFeed = AggregatorV3Interface(feeds_[3]);

    function setUp() public {
        ethFeed = new EthFeed();
        goldFeed = new GoldFeed();
        wtiFeed = new WtiFeed();

        address[] memory feeds = new address[](4);
        feeds[0] = address(wtiFeed);
        feeds[1] = address(); //volatility
        feeds[2] = address(ethFeed);
        feeds[3] = address(goldFeed);    

        ozOracle = new ozOracleFacet(); 
        diamond = new ozDiamond();
        init = new InitUpgradeV2(feeds);

        address[] memory selectors = new address[](1);
        selectors[0] = ozOracle.getLastPrice.selector;

        bytes4 initSelector = 
        bytes memory data = abi.encodeWithSelector(

        );

        FacetCut memory cut = FacetCut({
            facetAddress: ozOracle.address,
            action: FacetCutAction.Add,
            functionSelectors: selectors
        });

        vm.startPrank(deployer);
        diamond.diamondCut(cut, address(init), data);
    }

}


contract ozOracleFacetTest is Test {

    ozOracleFacet private ozOracle;
    WtiFeed private wtiFeed;
    EthFeed private ethFeed;
    GoldFeed private goldFeed;

    address volAddress = 0xbcD8bEA7831f392bb019ef3a672CC15866004536;

    function setUp() public {
        wtiFeed = new WtiFeed();
        ethFeed = new EthFeed();
        goldFeed = new GoldFeed();

        ozOracle = new ozOracleFacet(
            address(wtiFeed),
            volAddress,
            address(ethFeed),
            address(goldFeed)
        );

        vm.label(address(wtiFeed), 'wtiFeed');
        vm.label(address(ethFeed), 'ethFeed');
        vm.label(address(goldFeed), 'goldFeed');
        vm.label(volAddress, 'volFeed');
        vm.label(address(ozOracle), 'eETH');
    }

    function testLastPrice() public {
        uint price = ozOracle.getLastPrice();
        assertTrue(price > 0);
    }

    // function invariant_neverFails() public pure {
    //     bool success = true;
    //     require(success);
    // }

}