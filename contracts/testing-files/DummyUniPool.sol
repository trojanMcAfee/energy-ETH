// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;



contract DummyUniPool {
    function observe(uint256 secsAgo_) external view returns(
        int56[] memory tickCumulatives, 
        uint160[] memory secondsPerLiquidityCumulativeX128s
    ) 
    {
        tickCumulatives[0] = 72047099157089892 + (72047099157089892 / 1000);
        tickCumulatives[1] = 72047099155064522 + (72047099155064522 / 1000);

        secondsPerLiquidityCumulativeX128s[0] = 407410939321411974142743327702238;
        secondsPerLiquidityCumulativeX128s[1] = 407410939322460863660779625412580;
    }
}