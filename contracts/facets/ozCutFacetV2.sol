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

        bytes32 oracleID = _getOracleId(toRemove_);
        s.idToOracle[oracleID] = address(0);

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


    function _getOracleId(address oracle_) private returns(bytes32) {
        bytes memory data = abi.encodeWithSignature('getOracleIdByAddress(address)', oracle_);
        data = address(this).functionCall(data);
        return abi.decode(data, (bytes32));
    }


}