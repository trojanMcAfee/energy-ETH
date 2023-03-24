// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


// import '../../interfaces/ozIDiamond.sol';
import '../../contracts/testing-files/WtiFeed.sol';


contract EchidnaE2E {

    // ozIDiamond OZL = ozIDiamond(0x7D1f13Dd05E6b0673DC3D0BFa14d40A74Cfa3EF2);
    WtiFeed wtiFeed = WtiFeed(0x1dC4c1cEFEF38a777b15aA20260a54E584b16C48);


    // function get_price() public view  {
    //     uint256 price = OZL.getLastPrice();
    //     assert(price > 0);
    // }

    function get_round_data() public view  {
        (, int price,,,) = wtiFeed.latestRoundData();
        assert(price > 0);
    }

}