// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


/**
 * @notice Library of common methods using in both L1 and L2 contracts
 */
library LibCommon {

    /**
     * @notice L1 removal method
     * @dev Removes a token from the token database
     * @param array_ array of addresses where the removal will occur
     * @param toRemove_ token to remove
     */
    function remove(address[] storage array_, address toRemove_) internal {
        uint256 index;
        for (uint256 i=0; i < array_.length;) {
            if (array_[i] == toRemove_)  {
                index = i;
                break;
            }
            unchecked { ++i; }
        }
        for (uint256 i=index; i < array_.length - 1;){
            array_[i] = array_[i+1];
            unchecked { ++i; }
        }
        delete array_[array_.length-1];
        array_.pop();
    }


    /**
     * @dev "Semi-overload" of function from above, but for an array of bytes
     * instead of an array of addresses. 
     * @param array_ array of bytes where the removal will occur. 
     * @param toRemove_ bytes variable to remove. 
     */
    function remove(bytes[] storage array_, bytes memory toRemove_) internal {
        uint256 index;
        for (uint256 i=0; i < array_.length;) {
            
            bytes32 arrayEl = keccak256(abi.encodePacked(array_[i]));
            bytes32 toRemove = keccak256(abi.encodePacked(toRemove_));

            if (arrayEl == toRemove)  {
                index = i;
                break;
            }
            unchecked { ++i; }
        }
        for (uint256 i=index; i < array_.length - 1;){
            array_[i] = array_[i+1];
            unchecked { ++i; }
        }
        delete array_[array_.length-1];
        array_.pop();
    }


    /**
     * @dev "Semi-overload" of function from above, but for an array of
     * AggregatorV3Interface (Chainlink feeds) instead of an array of addresses. 
     * @param array_ array of Chainlink feeds.
     * @param toRemove_ Chailink feed to remove.
     */
    function remove(
        AggregatorV3Interface[] storage array_, 
        AggregatorV3Interface toRemove_
    ) internal 
    {
        uint256 index;
        for (uint256 i=0; i < array_.length;) {
            if (address(array_[i]) == address(toRemove_))  {
                index = i;
                break;
            }
            unchecked { ++i; }
        }
        for (uint256 i=index; i < array_.length - 1;){
            array_[i] = array_[i+1];
            unchecked { ++i; }
        }
        delete array_[array_.length-1];
        array_.pop();
    }
}