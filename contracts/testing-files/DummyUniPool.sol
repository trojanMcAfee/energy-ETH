// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "forge-std/console.sol";


contract DummyUniPool {

    function observe(uint32[] calldata secsAgo_) external pure returns(
        int56[] memory, 
        uint160[] memory
    ) 
    {
        int56[] memory tickCumulatives = new int56[](2);
        uint160[] memory secondsPerLiquidityCumulativeX128s = new uint160[](2);

        uint56 DENOMINATOR = uint56(1000);
        uint56 num2 = uint56(72047099157089892) / DENOMINATOR;
        uint56 num = uint56(72047099157089892) + (secsAgo_[0] * 0);
    
        tickCumulatives[0] = int56(int(uint(num) + (10 * uint(num2))));
        
        num2 = uint56(72047099155064522 / DENOMINATOR);
        num = uint56(72047099155064522);

        tickCumulatives[1] = int56(int(uint(num) + (10 * uint(num2))));

        secondsPerLiquidityCumulativeX128s[0] = uint160(407410939321411974142743327702238);
        secondsPerLiquidityCumulativeX128s[1] = uint160(407410939322460863660779625412580);

        return (tickCumulatives, secondsPerLiquidityCumulativeX128s);

    }
}