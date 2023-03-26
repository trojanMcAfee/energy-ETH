// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import '../../interfaces/ozIDiamond.sol';
import '../../contracts/testing-files/WtiFeed.sol';
import '../../contracts/testing-files/EthFeed.sol';
import '../../contracts/testing-files/GoldFeed.sol';
import '../../contracts/facets/ozOracleFacet.sol';
import '../../contracts/InitUpgradeV2.sol';

// import 'hardhat/console.sol';


contract EchidnaE2E {

    ozIDiamond OZL;

    WtiFeed private wtiFeed;
    EthFeed private ethFeed;
    GoldFeed private goldFeed;

    ozOracleFacet private ozOracle;
    InitUpgradeV2 private initUpgrade;

    address private volIndex = 0xbcD8bEA7831f392bb019ef3a672CC15866004536;
    
    constructor() {
        OZL = ozIDiamond(0x7D1f13Dd05E6b0673DC3D0BFa14d40A74Cfa3EF2);

        ethFeed = new EthFeed();
        goldFeed = new GoldFeed();
        wtiFeed = new WtiFeed();

        ozOracle = new ozOracleFacet(); 

        address[] memory facets = new address[](1);
        facets[0] = address(ozOracle);

        address[] memory feeds = new address[](4);
        feeds[0] = address(wtiFeed);
        feeds[1] = volIndex;
        feeds[2] = address(ethFeed);
        feeds[3] = address(goldFeed); 

        initUpgrade = new InitUpgradeV2();

        bytes memory data = abi.encodeWithSelector(
            initUpgrade.init.selector,
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

        OZL.diamondCut(cuts, address(initUpgrade), data);
    }


    // function get_price() public view  {
    //     uint256 price = OZL.getLastPrice();
    //     // uint256 price = OZL.getOzelIndex();

    //     // bytes memory data = abi.encodeWithSig
    //     // (bool success,) = address(OZL).call();

    //     assert(price > 0);
    // }

    // function get_round_data() public view  {
    //     (, int price,,,) = wtiFeed.latestRoundData();
    //     assert(price > 0);
    // }

    function getHello() public pure {
        assert(true);
    }

}