// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "forge-std/Test.sol";
import './Setup.sol';
import '../../interfaces/ozIDiamond.sol';
import { UC, ONE, ZERO } from "unchecked-counter/UC.sol";
import '../../Errors.sol';



contract ozOracleFacetTest is Test, Setup {

    using stdStorage for StdStorage;


    uint256 twapPrice = 1473593483134366243200;
    uint256 chainlinkPrice = 1425816593187981280000;
    

    /**
     * @dev Gets eETH price with TWAP's ETHUSD price as basePrice. 
     */
    function test_getEnergyPrice_twap() public {
        //Action
        uint256 price = OZL.getEnergyPrice();

        //Post-condition
        price == twapPrice ? assertTrue(true) : assertTrue(false);
    }


    /**
     * @dev Gets eETH price with Chainlink's ETHUSD price as basePrice, after TWAP
     * failed the 5% discrepancy check (higher than).
     */
    function test_getEnergyPrice_chainlink() public {
        //Pre-condition
        vm.selectFork(fork700);
        vm.roll(69254700);
        _runSetup();

        //Action
        uint256 price = OZL.getEnergyPrice();

        //Post-condition
        price == chainlinkPrice ? assertTrue(true) : assertTrue(false);
    }

    /*///////////////////////////////////////////////////////////////
                            Volatility Index
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Tests that you can successfully query Chainlink's volatility index.
     */
    function test_getVolatilityIndex() public {
        int256 index = OZL.getVolatilityIndex();
        assertTrue(index > 0);
    }

    /**
     * @dev Tests that you can successfully change Chainlink's volatility index.
     */
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

    /**
     * @dev Tests that an non-owner can't successfully change Chainlink's volatility index.
     */
    function test_fail_changeVolatilityIndex_notOwner() public {
        //Pre-condition
        address volAddr = _getVolAddress();
        assertTrue(volAddr == volIndex);

        //Action
        vm.expectRevert(notOwner);
        OZL.changeVolatilityIndex(AggregatorV3Interface(deadAddr));   
    }


    /**
     * @dev Tests that the owner can successfully change Chainlink's volatility index.
     */
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

    /**
     * @dev Tests that the owner can successfully add a Chainlink's price feed.
     */
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

    /**
     * @dev Tests that an non-owner can't successfully add a Chainlink's price feed.
     */
    function test_fail_addFeed_notOwner() public {
        //Pre-condition
        address[] memory feeds = OZL.getPriceFeeds();
        assertTrue(feeds.length == 3);

        //Action
        vm.expectRevert(notOwner);
        OZL.addFeed(AggregatorV3Interface(deadAddr));
    }

    /**
     * @dev Tests that a fee that's added already can't be re-added.
     */
    function test_fail_addFeed_alreadyFeed() public {
        //Action
        vm.prank(deployer);
        vm.expectRevert(
            abi.encodeWithSelector(AlreadyFeed.selector, address(wtiFeed))
        );
        OZL.addFeed(AggregatorV3Interface(address(wtiFeed)));
    }

    /**
     * @dev Tests that the owner can successfully remove a Chainlink's price feed.
     */
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

    /**
     * @dev Tests that an non-owner can't successfully remove a Chainlink's price feed.
     */
    function test_fail_removeFeed_notOwner() public {
        //Pre-condition
        address[] memory feeds = OZL.getPriceFeeds();
        assertTrue(feeds.length == 3);

        //Action
        vm.expectRevert(notOwner);   
        OZL.removeFeed(AggregatorV3Interface(address(wtiFeed)));
    }

    /**
     * @dev Tests that the owner can't remove a non-existent feed.
     */
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

    /**
     * @dev Tests that the owner can successfully change the Uniswap pool used for TWAP.
     */
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

    /**
     * @dev Tests that an non-owner can't successfully change the Uniswap pool used for TWAP.
     */
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