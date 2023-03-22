// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import '../../contracts/facets/EnergyETHFacet.sol';
import '../../interfaces/ozIDiamond.sol';


contract EnergyETHFacetTest is EnergyETHFacet {

    ozIDiamond OZL = ozIDiamond(0x7D1f13Dd05E6b0673DC3D0BFa14d40A74Cfa3EF2);

    constructor() {}

    function echidna_getEnergyPrice() public view returns(bool) {
        uint price = OZL.getEnergyPrice();
        return price > 0;
    }


}