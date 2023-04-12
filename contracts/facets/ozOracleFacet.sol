// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import '../AppStorage.sol';
import "forge-std/console.sol";
import '../../libraries/LibHelpers.sol';

// import 'hardhat/console.sol';

//add modularity to add and remove chainlink feeds
//add uniswap and trellors oracles as a fallback
contract ozOracleFacet {

    AppStorage s;

    using LibHelpers for *;
    // using Address for address;

    int256 private constant EIGHT_DEC = 1e8;
    int256 private constant NINETN_DEC = 1e19;


    //**** MAIN ******/

    function getEnergyPrice() external view returns(uint256) {
        //add isOpen modifier

        (DataInfo[] memory infoFeeds, int basePrice) = _getDataFeeds();
        // int256 volIndex = data.volIndex.value;

        // DataInfo memory wtiInfo = infoFeeds[0];
        // // int256 volIndex = infoFeeds[1].value;
        // DataInfo memory ethInfo = infoFeeds[1];
        // DataInfo memory goldInfo = infoFeeds[2];

        int256 volIndex = getVolatilityIndex();
        int256 netDiff;

        for (uint i=0; i < infoFeeds.length; i++) {
            DataInfo memory info = infoFeeds[i];

            netDiff += _setPrice(
                info, address(info.feed) == address(s.ethFeed) ? int256(0) : volIndex
            );
        }

        // int256 implWti = _setPrice(wtiInfo, volIndex); 
        // int256 implGold = _setPrice(goldInfo, volIndex);
        // int256 implEth = _setPrice(ethInfo, 0);

        // int256 netDiff = implWti + implEth + implGold;

        return uint256(basePrice + ( (netDiff * basePrice) / (100 * EIGHT_DEC) ));
    }


    function getVolatilityIndex() public view returns(int256) {
        (, int256 volatility,,,) = s.volatilityFeed.latestRoundData();
        return volatility;

        //--------
        // bytes memory data = abi.encodeWithSelector(s.volatilityFeed.latestRoundData.selector);
        // data = address(s.volatilityFeed).functionStaticCall(data);
        // (,int256 volatility,,,) = abi.decode(data, (uint80,int256,uint256,uint256,uint80));
        // return volatility;
    }


    function _callFeeds() private view returns(DataInfo[] memory) {
        DataInfo[] memory infos = new DataInfo[](s.feeds.length);

        for (uint i=0; i < s.feeds.length; i++) {
            (uint80 id, int256 value,,,) = s.feeds[i].latestRoundData();
            // if (address(s.feeds[i]) == address(s.volatilityFeed)) id = 0;

            DataInfo memory info = DataInfo({
                roundId: id,
                value: value,
                feed: s.feeds[i]
            });
            infos[i] = info;
        }
        return infos;
    }


    function _getDataFeeds() private view returns(DataInfo[] memory infoFeeds, int basePrice) {
        // (,int256 volatility,,,) = s.volatilityFeed.latestRoundData();
        // (uint80 wtiId, int256 wtiPrice,,,) = s.wtiFeed.latestRoundData();
        // (uint80 ethId, int256 ethPrice,,,) = s.ethFeed.latestRoundData();
        // (uint80 goldId, int256 goldPrice,,,) = s.goldFeed.latestRoundData();

        infoFeeds = _callFeeds();

        // basePrice = ethPrice.calculateBasePrice();
        basePrice = infoFeeds[1].value.calculateBasePrice();

        // data = Data({
        //     volIndex: DataInfo({
        //         roundId: 0,
        //         value: volatility
        //     }),
        //     wtiPrice: DataInfo({
        //         roundId: wtiId,
        //         value: wtiPrice
        //     }),
        //     ethPrice: DataInfo({
        //         roundId: ethId,
        //         value: ethPrice
        //     }),
        //     goldPrice: DataInfo({
        //         roundId: goldId,
        //         value: goldPrice
        //     })
        // });
    }

    //------------------

    function _setPrice(
        DataInfo memory feedInfo_, 
        int256 volIndex_
        // AggregatorV3Interface feed_
    ) private view returns(int256) {
        if (address(feedInfo_.feed) != address(s.ethFeed)) {
            int256 currPrice = feedInfo_.value;
            int256 netDiff = currPrice - feedInfo_.roundId.getPrevFeed(feedInfo_.feed);
            return ( (netDiff * 100 * EIGHT_DEC) / currPrice ) * (volIndex_ / NINETN_DEC);
        } else {
            int256 prevEthPrice = feedInfo_.roundId.getPrevFeed(feedInfo_.feed);
            int256 netDiff = feedInfo_.value - prevEthPrice;
            return (netDiff * 100 * EIGHT_DEC) / prevEthPrice;
        }
    }


}




