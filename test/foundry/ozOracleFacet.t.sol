// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "forge-std/Test.sol";
import './Setup.sol';
import '../../interfaces/ozIDiamond.sol';
import { UC, ONE, ZERO } from "unchecked-counter/UC.sol";
import '../../Errors.sol';

import "forge-std/console.sol";


contract ozOracleFacetTest is Test, Setup {

    using stdStorage for StdStorage;


    uint256 twapPrice = 20750118741723922336800; //1473593483134366243200
    uint256 chainlinkPrice = 1475510304606752115200; //1425816593187981280000
    

    //Gets eETH price with a basePrice of TWAP price
    function test_getEnergyPrice_twap() public {
        //Action
        uint256 price = OZL.getEnergyPrice();

        //Post-condition
        console.log('price: ', price);
        price == twapPrice ? assertTrue(true) : assertTrue(false);
    }

    //Gets eETH price with a basePrice of Chainlink after discrepancy with TWAP 
    //was higher than 5% (also different with previous reading was checked)
    function test_getEnergyPrice_chainlink() public {
        //Pre-condition
        vm.selectFork(fork700);
        _runSetup();

        //Action
        uint256 price = OZL.getEnergyPrice();

        //Post-condition
        console.log('price: ', price);
        price == chainlinkPrice ? assertTrue(true) : assertTrue(false);
    }

    /*///////////////////////////////////////////////////////////////
                            Volatility Index
    //////////////////////////////////////////////////////////////*/

    function test_getVolatilityIndex() public {
        int256 index = OZL.getVolatilityIndex();
        assertTrue(index > 0);
    }

    function test_changeVolatilityIndex() public {
        //Pre-condition
        address volAddr = _getVolAddress();
        assertTrue(volAddr == volIndex);

        //Action
        vm.prank(deployer);
        OZL.changeVolatilityIndex(AggregatorV3Interface(deadAddr));

        //Post-condition
        volAddr = _getVolAddress();
        assertTrue(volAddr == deadAddr);
    }

    function test_fail_changeVolatilityIndex_notOwner() public {
        //Pre-condition
        address volAddr = _getVolAddress();
        assertTrue(volAddr == volIndex);

        //Action
        vm.expectRevert(notOwner);
        OZL.changeVolatilityIndex(AggregatorV3Interface(deadAddr));   
    }

    function test_change_getVolatilityIndex() public {
        //Pre-condition
        bytes4 selector = ozOracle.getVolatilityIndex.selector;
        address facet = OZL.facetAddress(selector);
        assertTrue(facet == address(ozOracle));

        //Action
        ozIDiamond.FacetCut[] memory cuts = new ozIDiamond.FacetCut[](1);
        cuts[0] = _createCut(address(newOracle), 4);

        vm.prank(deployer);
        OZL.diamondCut(cuts, address(0), '');

        //Post-action
        facet = OZL.facetAddress(selector);
        assertTrue(facet == address(newOracle));
    }

    /*///////////////////////////////////////////////////////////////
                            Add/Remove feed
    //////////////////////////////////////////////////////////////*/

    function test_addFeed() public {
        //Pre-condition
        address[] memory feeds = OZL.getPriceFeeds();
        assertTrue(feeds.length == 3);

        //Action
        vm.prank(deployer);
        OZL.addFeed(AggregatorV3Interface(deadAddr));

        //Post-condition
        feeds = OZL.getPriceFeeds();
        assertTrue(feeds.length == 4);
    }

    function test_fail_addFeed_notOwner() public {
        //Pre-condition
        address[] memory feeds = OZL.getPriceFeeds();
        assertTrue(feeds.length == 3);

        //Action
        vm.expectRevert(notOwner);
        OZL.addFeed(AggregatorV3Interface(deadAddr));
    }

    function test_fail_addFeed_alreadyFeed() public {
        //Action
        vm.prank(deployer);
        vm.expectRevert(
            abi.encodeWithSelector(AlreadyFeed.selector, address(wtiFeed))
        );
        OZL.addFeed(AggregatorV3Interface(address(wtiFeed)));
    }

    function test_removeFeed() public {
        //Pre-condition
        address[] memory feeds = OZL.getPriceFeeds();
        assertTrue(feeds.length == 3);

        //Action
        vm.prank(deployer);
        OZL.removeFeed(AggregatorV3Interface(address(wtiFeed)));

        //Post-condtion
        feeds = OZL.getPriceFeeds();
        assertTrue(feeds.length == 2);

        uint256 length = feeds.length;
        for (UC i=ZERO; i < uc(length); i = i + ONE) {
            address feed = feeds[i.unwrap()];
            if (feed == address(wtiFeed)) revert();
        }
        assertTrue(true);
    }

    function test_fail_removeFeed_notOwner() public {
        //Pre-condition
        address[] memory feeds = OZL.getPriceFeeds();
        assertTrue(feeds.length == 3);

        //Action
        vm.expectRevert(notOwner);   
        OZL.removeFeed(AggregatorV3Interface(address(wtiFeed)));
    }

    function test_fail_removeFeed_notFeed() public {
        //Action
        vm.prank(deployer);
        vm.expectRevert(
            abi.encodeWithSelector(NotFeed.selector, deadAddr)
        );
        OZL.removeFeed(AggregatorV3Interface(deadAddr));
    }

    /*///////////////////////////////////////////////////////////////
                            Change pool
    //////////////////////////////////////////////////////////////*/

    function test_changePool() public {
        //Pre-condition
        address uniPool = OZL.getUniPool();
        assertTrue(uniPool == ethUsdcPool);

        //Action
        vm.prank(deployer);
        OZL.changeUniPool(deadAddr);

        //Post-condition
        uniPool = OZL.getUniPool();
        assertTrue(uniPool == deadAddr);
    }

    function test_fail_changePool_notOwner() public {
        //Pre-condition
        address uniPool = OZL.getUniPool();
        assertTrue(uniPool == ethUsdcPool);

        //Action
        vm.expectRevert(notOwner);
        OZL.changeUniPool(deadAddr);
    }

    /*///////////////////////////////////////////////////////////////
                            Helpers
    //////////////////////////////////////////////////////////////*/

    function _getVolAddress() private view returns(address volAddr) {
        bytes32 volSlot = vm.load(address(OZL), bytes32(uint256(63)));
        volAddr = address(bytes20(volSlot << 96));
    }
   

}