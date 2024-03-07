# Energy ETH

### Purpose 
This project was intended to be version 2.0.0 of Ozel, but its efforts were halted at the moment due to a shift in the priorities of the system.
Ozel is trying to be a trust-minimized concept with the least amount possible of offchain dependencies, and the vision of Energy ETH was requesting some serious offchain efforts for it to be a reality. 

### Vision 
Energy ETH is an index composed of Ether (`ETH`) as the base price (`basePrice`) of the asset, and which primarily defines its behavior + the price action of Gold and WTI Crude Oil, which are both multiplied by Chainlink's Crypto Volatility index in order to amplify these differences and create a more influential performance. 

The price action of boths assets (`XAU` and `WTI`) is then combined and added to `basePrice` (which is `ETH`) to then form a new asset, that acts as an index, with an unique market behavior, and that it's heavily influenced by the commodities and energy markets. Hence, the name: Energy ETH. 

### Current State
This project, at the moment, is a very raw proof-of-concept, that haven't been polished nor tested for production, but it's worth noting that the price feed itself (`eETH`), the one described below, **WORKS** without issues.

The project, like Ozel v1, would be deployed to Arbitrum One.

### Business & Logical Specs 
When getting the price of `eETH`, the following flow happens: 
- The current values for `XAU` and `WTI` are queried.
- The current (`basePrice`) value of `ETH` is queried.
   - Its original source is Uniswap v3 spot TWAP oracle of the ETHUSD 0.05% pool, but there's an anti-manipulation mechanism in place that if the difference of Uniswap's oracle is bigger by more than 5%, then it defaults to the Chainlink's price feed for ETHUSD as `basePrice`.
- The previous value of ETH is queried.
   - Chainlink's price feed is used here.
- The net differences between the current and previous price updates for `XAU` and `WTI` are calculated independently, elevated to a 100% percentage scale, the result multiplied by Chainlink's Crypto Volatility Index, and the product of each set of operations (one for `XAU` and oe for `WTI`) are added together, and then combined to `basePrice`.

This gives us an asset that follows `ETH` trend, but it diverges towards its own price action due to the influence of `XAU` and `WTI`. 

### Technical specifications
- It's an extension of Ozel v1's Diamond pattern (EIP-2535), in the sense that it's an upgrade done through the `diamondCut()` function described in the specs of the EIP.
- It uses the following Chainlink price feeds (on Arbitrum One) for calculating `eETH`:
    - ETH/USD: `0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612`.
    - XAU/USD: `0x1F954Dc24a49708C26E0C1777f16750B5C6d5a2c`.
    - WTI/USD: `0x594b919AD828e693B935705c3F816221729E7AE8`.
         - The actual feeds from above are not used themselves since the project is not live in Arbitrum mainnet, but it does use mocks that comform to the `AggregatorV3Interface` specs, which is the interface used by Chainlink's price feeds.
    - Volatility Index: `0xbcD8bEA7831f392bb019ef3a672CC15866004536` (used)
- It uses Uniswap's TWAP spot oracle of the ETH/USD 0.05% for the calculation of `basePrice`.
- `Permit2` is used to be able to mint new `eETH` tokens without an approval.
- It also has the possibility to add more assets/prices to the calculation of `eETH` due to the upgradeability of the system.

