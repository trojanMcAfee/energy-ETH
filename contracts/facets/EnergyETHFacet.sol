// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
// import './ozOracleFacet.sol';


contract EnergyETHFacet {


    function getEnergyPrice() external pure returns(uint256) {
        // bytes memory data = abi.encodeWithSignature('getLastPrice');
        // data = Address.functionStaticCall(address(this), data);
        // return abi.decode(data, (uint256));

        return 3;
    }


}