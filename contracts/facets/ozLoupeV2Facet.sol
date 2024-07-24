// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import { UC, ONE, ZERO, uc } from "unchecked-counter/UC.sol";
import '../AppStorage.sol';


/**
 * @title 2nd version of contract for querying main variables and
 * system stats.
 * @dev Adds new view methods for the new storage variables added in 
 * in this upgrade. 
 */
contract ozLoupeV2Facet {

    AppStorage s;


    /**
     * @dev Gets how many protocol fees have failed to be deposited
     * into DeFi since the last failed attempt.
     * @return total of failed fees.
     */
    function getFeesVault() external view returns(uint256) {
        return s.feesVault;
    }

    
    /**
     * @dev Gets the amount of indexes/oracle that take part into the system.
     * @return address of all oracles/indexes/
     */
    function getOracles() external view returns(address[] memory) {
        uint256 length = s.oracles_ids.length;
        address[] memory oracles = new address[](length);
 
        for (UC i=ZERO; i < uc(length); i = i + ONE) {
            uint256 j = i.unwrap();
            bytes memory oracleDetails = s.oracles_ids[j];
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

    /**
     * @dev Gets the ID of an oracle in the system by its address/
     * @param oracle_ address of oracle to query.
     * @return ID of the oracle being queried.
     */
    function getOracleIdByAddress(address oracle_) public view returns(bytes32) {
        bytes32 oracleBytes = bytes32(abi.encode(oracle_));
        bytes32 oracleID;

        uint256 length = s.oracles_ids.length;
        for (UC i=ZERO; i < uc(length); i = i + ONE) {
            bytes memory oracleDetails = s.oracles_ids[i.unwrap()];
            bytes32 possOracle;

            assembly {
                possOracle := mload(add(oracleDetails, 32))
            }

            if (oracleBytes == possOracle) {
                assembly {
                    oracleID := mload(add(oracleDetails, 64))
                }
            }
        }
        return oracleID;
    }

    /**
     * @dev Gets the address of an oracle within the system by its ID.
     * @param id_ ID of the oracle to query. 
     * @return address of the oracle being queried.
     */
    function getOracleAddressById(bytes32 id_) external view returns(address) {
        return s.idToOracle[id_];
    }
}