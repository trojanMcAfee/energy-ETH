// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


// import 'ds-test/test.sol';
import "forge-std/Test.sol";
import "forge-std/console.sol";
import '../../contracts/ozOracleFacet.sol';
import '../../contracts/testing-files/WtiFeed.sol';
import '../../contracts/testing-files/EthFeed.sol';
import '../../contracts/testing-files/GoldFeed.sol';


contract ozOracleFacetTest is Test {

    function setUp() public {
        ozOracle = new ozOracleFacet();
        
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