// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import 'hardhat/console.sol';

contract EthUsdFeed {

    function latestRoundData() external view returns(int, int, int, int, int) {
        uint blockNum = block.number;
        int result;

        assembly {
            switch blockNum 
            case 69254394 { result := 154700260000 } 
            case 69255694 { result := 158142799097 } 
            case 69260694 { result := 158956580000 } 
            case 69294694 { result := 161684899390 } 
            case 69295694 { result := 161691000000 } 
            case 69297694 { result := 161566898000 } 
            case 69380694 { result := 160800635124 } 
            case 69421694 { result := 158595420000 } 
        }

        return (1,result,0,0,0);
    }

    function getRoundData(uint80 roundId_) external view returns(int, int, int, int, int) {
        uint blockNum = block.number;
        int result = int(uint(roundId_) - uint(roundId_));

        assembly {
            switch blockNum 
            case 69254394 { result := 158142799097 }
            case 69255694 { result := 158956580000 }
            case 69260694 { result := 161684899390 }
            case 69294694 { result := 161691000000 }
            case 69295694 { result := 161566898000 }
            case 69297694 { result := 160800635124 }
            case 69380694 { result := 158595420000 }
            case 69421694 { result := 154700260000 }
        }

        return (0,result,0,0,0);
    }
}