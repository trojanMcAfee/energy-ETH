// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


contract GoldFeed {

    function latestRoundData() external view returns(int, int, int, int, int) {
        uint blockNum = block.number;
        int result;

        assembly {
            switch blockNum 
            case 69254397 { result := 188117000000 } 
            case 69255697 { result := 189157000000 } 
            case 69260697 { result := 189157000000 } 
            case 69294697 { result := 188161500000 } 
            case 69295697 { result := 188161500000 } 
            case 69297697 { result := 188161500000 } 
            case 69380697 { result := 187211000000 } 
            case 69421697 { result := 188220158450 } 
        }

        return (1,result,0,0,0);
    }

    function getRoundData(uint80 roundId_) external view returns(int, int, int, int, int) {
        uint blockNum = block.number;
        int result = int(uint(roundId_) - uint(roundId_));

        assembly {
            switch blockNum 
            case 69254397 { result := 188917000000 }
            case 69255697 { result := 190157000000 }
            case 69260697 { result := 186757000000 }
            case 69294697 { result := 187261500000 }
            case 69295697 { result := 191261500000 }
            case 69297697 { result := 187161500000 }
            case 69380697 { result := 186011000000 }
            case 69421697 { result := 185720158450 }
        }

        return (0,result,0,0,0);
    }
}