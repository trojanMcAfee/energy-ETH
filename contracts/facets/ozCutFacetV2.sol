// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import { UC, ONE, ZERO } from "unchecked-counter/UC.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import '../../libraries/LibDiamond.sol';
import '../../libraries/LibHelpers.sol';
import '../../libraries/LibCommon.sol';
import '../AppStorage.sol';


contract ozCutFacetV2 {

    AppStorage s;

    using Address for address;

    event OracleAdded(address newOracle, bytes32 id);
    event OracleRemoved(address removedEl);


    function addOracle(address newOracle_, bytes32 id_) external {
        LibDiamond.enforceIsContractOwner();

        bytes memory oracleDetails = abi.encode(bytes20(newOracle_), id_); 
        s.idToOracle[id_] = newOracle_;
        s.oraclesToIds.push(oracleDetails);

        emit OracleAdded(newOracle_, id_);
    }


    function removeOracle(address toRemove_) external {
        LibDiamond.enforceIsContractOwner();

        // bytes32 oracleID = getOracleIdByAddress(toRemove_);

        bytes memory data = abi.encodeWithSignature('getOracleIdByAddress(address)', toRemove_);
        data = address(this).functionCall(data);
        bytes32 oracleID = abi.decode(data, (bytes32));
        
        s.idToOracle[oracleID] = address(0);
        // LibCommon.remove(s.oracles, toRemove_);

        for (uint i=0; i < s.oraclesToIds.length; i++) {
            bytes memory oracleDetails  = s.oraclesToIds[i];
            bytes32 possId;

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


    // function getOracles() external view returns(address[] memory) {
    //     uint256 length = s.oraclesToIds.length;
    //     address[] memory oracles = new address[](length);
 
    //     for (UC i=ZERO; i < uc(length); i = i + ONE) {
    //         uint256 j = i.unwrap();
    //         bytes memory oracleDetails = s.oraclesToIds[j];
    //         bytes32 oracle;

    //         assembly {
    //             oracle := mload(add(oracleDetails, 32))
    //         }

    //         oracles[j] = address(bytes20(oracle));
    //     }
    //     return oracles;
    // }


    // function getOracleIdByAddress(address oracle_) public view returns(bytes32) {
    //     // uint256 i = LibHelpers.indexOf(oracles, oracle_);

    //     bytes32 oracleBytes = bytes32(bytes20(oracle_));

    //     uint256 length = s.oraclesToIds.length;
    //     for (UC i=ZERO; i < uc(length); i = i + ONE) {
    //         bytes memory oracleDetails = s.oraclesToIds[i.unwrap()];
    //         bytes32 possOracle;

    //         assembly {
    //             possOracle := mload(add(oracleDetails, 32))
    //         }

    //         if (oracleBytes == possOracle) {
    //             bytes32 oracleID;
    //             assembly {
    //                 oracleID := mload(add(oracleDetails, 64))
    //             }
    //             return oracleID;
    //         }
    //     }
    //     return bytes32(0);
    // }


    // function getOracleAddressById(bytes32 id_) external view returns(address) {
    //     return s.idToOracle[id_];
    // }



}