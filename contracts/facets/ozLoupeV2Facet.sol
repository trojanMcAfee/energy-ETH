// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import { UC, ONE, ZERO, uc } from "unchecked-counter/UC.sol";
import '../AppStorage.sol';

import "forge-std/console.sol";

contract ozLoupeV2Facet {

    AppStorage s;


    function getFeesVault() external view returns(uint256) {
        return s.feesVault;
    }

    //-------

    function getOracles() external view returns(address[] memory) {
        uint256 length = s.oraclesToIds.length;
        address[] memory oracles = new address[](length);
 
        for (UC i=ZERO; i < uc(length); i = i + ONE) {
            uint256 j = i.unwrap();
            bytes memory oracleDetails = s.oraclesToIds[j];
            bytes32 oracleBytes32;
            bytes20 oracle;

            assembly {
                oracleBytes32 := mload(add(oracleDetails, 32))
                oracle := shl(96, oracleBytes32)
            }
            
            oracles[j] = address(oracle);
        }
        return oracles;
    }


    function getOracleIdByAddress(address oracle_) public view returns(bytes32) {
        // uint256 i = LibHelpers.indexOf(oracles, oracle_);

        bytes32 oracleBytes = bytes32(bytes20(oracle_));

        uint256 length = s.oraclesToIds.length;
        for (UC i=ZERO; i < uc(length); i = i + ONE) {
            bytes memory oracleDetails = s.oraclesToIds[i.unwrap()];
            bytes32 possOracle;

            assembly {
                possOracle := mload(add(oracleDetails, 32))
            }

            if (oracleBytes == possOracle) {
                bytes32 oracleID;
                assembly {
                    oracleID := mload(add(oracleDetails, 64))
                }
                return oracleID;
            }
        }
        return bytes32(0);
    }


    function getOracleAddressById(bytes32 id_) external view returns(address) {
        return s.idToOracle[id_];
    }

}