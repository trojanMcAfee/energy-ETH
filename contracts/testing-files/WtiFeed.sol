// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;

import 'hardhat/console.sol';

contract WtiFeed {

    function latestRoundData() external view returns(int, int, int, int, int) {
        uint blockNum = block.number;
        int result;

        assembly {
            switch blockNum 
            case 69254394 { result := 7632500000 } 
            case 69255694 { result := 7672000000 } 
            case 69260694 { result := 7717200000 } 
            case 69294694 { result := 7677600000 } 
            case 69295694 { result := 7704200000 } 
            case 69297694 { result := 7639200000 } 
            case 69380694 { result := 7674920000 } 
            case 69421694 { result := 7592500000 } 
        }

        return (0,result,0,0,0);
    }

    function getRoundData(uint80 roundId_) external view returns(int, int, int, int, int) {
        
    }
}