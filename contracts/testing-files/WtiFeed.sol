// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;

import 'hardhat/console.sol';

contract WtiFeed {

    function latestRoundData() external view returns(int, int, int, int, int) {
        uint blockNum = block.number;
        int result;
        console.log('blockNum: ', blockNum);

        assembly {
            switch blockNum
            case 69254393 { result := 7632500000 }
            case 69255693 { result := 7672000000 }
            case 69260693 { result := 7717200000 }
            case 69294691 { result := 7677600000 }
            case 69293691 { result := 7717200000 }
            case 69295691 { result := 7677600000 }
            case 69212691 { result := 7674920000 }
            case 69253691 { result := 7632500000 }
        }

        return (0,result,0,0,0);
    }
}