// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import { UC, ONE, ZERO } from "unchecked-counter/UC.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import '../../libraries/LibDiamond.sol';
import '../../libraries/LibHelpers.sol';
import '../../libraries/LibCommon.sol';
import '../AppStorage.sol';


/**
 * @title 2nd version of ozCutFacet within ozDiamond.
 * @notice Contracts that adds to the main write admin functions of the system. 
 */
contract ozCutFacetV2 {

    AppStorage s;

    using Address for address;

    event OracleAdded(address newOracle, bytes32 id);
    event OracleRemoved(address removedEl);

    /**
     * @dev Adds a new oracle facet (for potentitally adding more indexes).
     * @param newOracle_ address of new oracle facet.
     */
    function addOracle(address newOracle_, bytes32 id_) external {
        LibDiamond.enforceIsContractOwner();

        bytes memory oracleDetails = abi.encode(bytes20(newOracle_), id_); 
        s.idToOracle[id_] = newOracle_;
        s.oracles_ids.push(oracleDetails);

        emit OracleAdded(newOracle_, id_);
    }

    /**
     * @dev Removes an oracle facet from the system.
     * @param toRemove_ address of facet to remove.
     */
    function removeOracle(address toRemove_) external {
        LibDiamond.enforceIsContractOwner();

        bytes32 oracleID = _getOracleId(toRemove_);
        s.idToOracle[oracleID] = address(0);

        for (uint i=0; i < s.oracles_ids.length; i++) {
            bytes memory oracleDetails  = s.oracles_ids[i];
            bytes32 possId;

            assembly {
                possId := mload(add(oracleDetails, 64))
            }

            if (possId == oracleID) {
                LibCommon.remove(s.oracles_ids, oracleDetails);
                emit OracleRemoved(toRemove_);
            }
        }
    }

    /**
     * @dev Gets the internal ID of an oracle within the system.
     * @param oracle_ address of the oracle to query.
     * @return ID of the oracle. 
     */
    function _getOracleId(address oracle_) private returns(bytes32) {
        bytes memory data = abi.encodeWithSignature('getOracleIdByAddress(address)', oracle_);
        data = address(this).functionCall(data);
        return abi.decode(data, (bytes32));
    }
}