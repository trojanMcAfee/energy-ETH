// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import { UC, uc } from "unchecked-counter/UC.sol";


/**
 * @notice Library of common methods using in both L1 and L2 contracts
 */
library LibCommon {

    /**
     * @notice L1 removal method
     * @dev Removes a token from the token database
     * @param array_ Array of addresses where the removal will occur
     * @param toRemove_ Token to remove
     */
    function remove(address[] storage array_, address toRemove_) internal {
        uint index;
        for (uint i=0; i < array_.length;) {
            if (array_[i] == toRemove_)  {
                index = i;
                break;
            }
            unchecked { ++i; }
        }
        for (uint i=index; i < array_.length - 1;){
            array_[i] = array_[i+1];
            unchecked { ++i; }
        }
        delete array_[array_.length-1];
        array_.pop();
    }


    function remove(bytes[] storage array_, bytes memory toRemove_) internal {
        // bytes32 oracleBytes = bytes32(bytes20(toRemove_));
        
        uint index;
        for (uint i=0; i < array_.length;) {
            // bytes memory oracleDetails = array_[i];
            bytes32 arrayEl = keccak256(abi.encodePacked(array_[i]));
            bytes32 toRemove = keccak256(abi.encodePacked(toRemove_));

            if (arrayEl == toRemove)  {
                index = i;
                break;
            }
            unchecked { ++i; }
        }
        for (uint i=index; i < array_.length - 1;){
            array_[i] = array_[i+1];
            unchecked { ++i; }
        }
        delete array_[array_.length-1];
        array_.pop();
    }

}