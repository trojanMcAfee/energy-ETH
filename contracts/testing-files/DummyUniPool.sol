// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;



contract DummyUniPool {

    function observe(uint256 secsAgo_) external pure returns(
        int56[] memory tickCumulatives, 
        uint160[] memory secondsPerLiquidityCumulativeX128s
    ) 
    {
        uint56 DENOMINATOR = 1000;

        tickCumulatives[0] = int56(uint56(72047099157089892) + (uint56(72047099157089892) / DENOMINATOR));
        tickCumulatives[1] = int56(uint56(72047099155064522) + (uint56(72047099155064522) / DENOMINATOR));

        secondsPerLiquidityCumulativeX128s[0] = uint160(407410939321411974142743327702238);
        secondsPerLiquidityCumulativeX128s[1] = uint160(407410939322460863660779625412580);

    }
}