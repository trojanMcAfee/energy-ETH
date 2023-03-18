// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


// import 'ds-test/test.sol';
import "forge-std/Test.sol";
import "forge-std/console.sol";
import '../../contracts/EnergyETHFacet.sol';
import '../../contracts/testing-files/WtiFeed.sol';
import '../../contracts/testing-files/EthUsdFeed.sol';


contract EnergyETHFacetTest is Test {

    EnergyETHFacet private energyETH;
    WtiFeed private wtiFeed;
    EthUsdFeed private ethFeed;

    address volAddress = 0xbcD8bEA7831f392bb019ef3a672CC15866004536;

    function setUp() public {
        wtiFeed = new WtiFeed();
        ethFeed = new EthUsdFeed();
        vm.label(address(wtiFeed), 'wtiFeed');
        vm.label(address(ethFeed), 'ethFeed');

        energyETH = new EnergyETHFacet(
            address(wtiFeed),
            volAddress,
            address(ethFeed)
        );
        vm.label(address(energyETH), 'eETH');
        vm.label(volAddress, 'volFeed');
    }

    function testExample(uint num_) public {
        require(num_ != 0);
        bool success = num_ > 2000 ? true : false;
        assertTrue(success);
    }

    function testLastPrice() public view {
        energyETH.getLastPrice();
    }

    function invariant_neverFails() public pure {
        bool success = true;
        require(success);
    }


}