// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;

import 'hardhat/console.sol';

contract WtiFeed {

    function latestRoundData() external view returns(int, int, int, int, int) {
        uint blockNum = block.number;
        int result;

        assembly {
            switch blockNum 
            case 69254393 { result := 7632500000 } //0
            case 69255693 { result := 7672000000 } //1
            case 69260693 { result := 7717200000 } //2
            case 69294693 { result := 7677600000 } //3
            case 69295693 { result := 7704200000 } //4
            case 69297693 { result := 7639200000 } //5
            case 69380693 { result := 7674920000 } //6
            case 69421693 { result := 7592500000 } //7
        }

        return (0,result,0,0,0);
    }
}