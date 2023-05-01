// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "forge-std/console.sol";


contract DummyUniPool {

    function observe(uint32[] calldata secsAgo_) external view returns(
        int56[] memory, 
        uint160[] memory
    ) 
    {
        int56[] memory tickCumulatives = new int56[](2);
        uint160[] memory secondsPerLiquidityCumulativeX128s = new uint160[](2);

        // uint256 deadVar = secsAgo_;
        // delete secsAgo_;
        uint56 DENOMINATOR = uint56(1000);
        // console.logUint((uint56(72047099157089892) / DENOMINATOR));
        uint56 num2 = uint56(72047099157089892) / DENOMINATOR;
        uint56 num = uint56(72047099157089892);


        // tickCumulatives[0] = int56(uint56(72047099157089892) + (uint56(72047099157089892) / DENOMINATOR));
    
        // uint sum = uint(num) + uint(num2);
        tickCumulatives[0] = int56(int(uint(num) + (10 * uint(num2))));
        // tickCumulatives[1] = int56(uint56(72047099155064522) + (uint56(72047099155064522) / DENOMINATOR));
        
        num2 = uint56(72047099155064522 / DENOMINATOR);
        num = uint56(72047099155064522);
        tickCumulatives[1] = int56(int(uint(num) + (10 * uint(num2))));

        console.log(7);

        secondsPerLiquidityCumulativeX128s[0] = uint160(407410939321411974142743327702238);
        secondsPerLiquidityCumulativeX128s[1] = uint160(407410939322460863660779625412580);

        console.log('secondsPerLiquidityCumulativeX128s[0]: ', secondsPerLiquidityCumulativeX128s[0]);
        console.log('secondsPerLiquidityCumulativeX128s[1]: ', secondsPerLiquidityCumulativeX128s[1]);

        console.log('tickCumulatives[0]: ', uint56(tickCumulatives[0]));
        console.log('tickCumulatives[1]: ', uint56(tickCumulatives[1]));


        return (tickCumulatives, secondsPerLiquidityCumulativeX128s);

    }
}