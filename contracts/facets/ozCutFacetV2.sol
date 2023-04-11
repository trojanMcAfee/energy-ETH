// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import { UC, uc } from "unchecked-counter/UC.sol";
import '../../libraries/LibDiamnond.sol';
import '../../libraries/LibHelpers.sol';
import '../../libraries/LibCommon.sol';


contract ozCutFacetV2 {

    AppStorage s;

    event OracleAdded(address newOracle, bytes32 id);
    event OracleRemoved(address removedEl);


    function addOracle(address newOracle_, bytes32 id_) external {
        LibDiamond.enforceIsContractOwner();

        bytes memory oracleDetails = abi.encode(bytes20(newOracle_), id_); 
        s.oracleIDs[id_] = newOracle_;
        s.oraclesToIds.push(oracleDetails);

        emit OracleAdded(newOracle_, id_);
    }


    function removeOracle(address toRemove_) external {
        LibDiamond.enforceIsContractOwner();

        bytes32 oracleID = getOracleIdByAddress(toRemove_);
        idToOracle[oracleID] = address(0);
        
        s.oracleIDs[toRemove_] = new bytes32(0);
        // LibCommon.remove(s.oracles, toRemove_);

        for (uint i=0; i < s.oraclesToIds.length; i++) {
            bytes memory oracleDetails  = s.oraclesToIds[i];
            bytes memory possId;

            assembly {
                possId := mload(add(oracleDetails, 64))
            }

            if (possId == oracleID) {
                LibCommon.remove(s.oraclesToIds, oracleDetails);
                emit OracleRemoved(toRemove_);
            }

        }
        //use them as access control in diff functions

        
    }


    function getOracles() external view returns(address[] memory) {
        uint256 length = s.oraclesToIds.length;
        address[] memory oracles = new address[](length);
 
        for (uint256 i=uc(0); i < uc(length); i = i + uc(1)) {
            uint256 ii = i.unwrap();
            oracles[ii] = s.oraclesToIds[ii][0];
            bytes32 oracle;

            assembly {
                oracle := mload(add(oracleDetails, 32))
            }

            oracles[ii] = address(oracle);
        }
        return oracles;
    }


    function getOracleIdByAddress(address oracle_) public view returns(bytes32) {
        // uint256 i = LibHelpers.indexOf(oracles, oracle_);

        bytes32 oracleBytes = bytes20(oracle);

        uint256 length = s.oraclesToIds.length;
        for (uint256 i=uc(0); i < uc(length); i = i + uc(1)) {
            bytes memory oracleDetails = s.oraclesToIds[i.unwrap()];
            bytes32 possOracle;

            assembly {
                possOracle := mload(add(oracleDetails, 32))
            }

            if (oracleBytes == possOracle) {
                bytes32 oracle;
                assembly {
                    oracle := mload(add(oracleDetails, 64))
                }
                return address(bytes20(oracle));
            }
        }
    }


    function getOracleAddressById(bytes32 id_) external view returns(address) {
        return IdToOracle[id];
    }



}