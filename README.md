# Energy ETH

## Purpose 
This project was intended to be version 2.0.0 of [Ozel](https://ozelprotocol.xyz/) ([docs](https://docs.ozelprotocol.xyz/)), but its efforts were halted at the moment due to a shift in the priorities of the system.
Ozel is trying to be a trust-minimized concept with the least amount possible of offchain dependencies, and the original vision of Energy ETH was requiring some serious offchain efforts for it to be a reality. 

## Vision 
Energy ETH is an index composed of Ether (`ETH`) as the base price (`basePrice`) of the asset, and which primarily defines its behavior + the price action of Gold and WTI Crude Oil, which are both multiplied by Chainlink's Crypto Volatility index in order to amplify these differences and create a more influential performance. 

The price action of boths assets (`XAU` and `WTI`) is then combined and added to `basePrice` (which is `ETH`) to then form a new asset, that acts as an index, with an unique market behavior, and that it's heavily influenced by the commodities and energy markets. Hence, the name: Energy ETH. 

## Current State
This project, at the moment, is a very raw proof-of-concept, that haven't been polished nor tested for production, but it's worth noting that the price feed itself (`eETH`), the one described below, **WORKS** without issues.

The project, like Ozel v1, would be deployed to Arbitrum One.

## Business & Logical Specs 
When getting the price of `eETH`, the following flow happens: 
- The current and previous values for `XAU` and `WTI` are queried.
- The current value of `ETH` is queried (`basePrice`).
   - Its original source is Uniswap v3's spot TWAP oracle of the ETHUSD 0.05% pool with 10 seconds of time-weighted means, but there's an anti-manipulation mechanism in place that if the difference of Uniswap's oracle and Chainlink's previous price update is bigger than 5%, then it defaults to the Chainlink's price feed for ETHUSD as `basePrice`.
- The previous value of `ETH` is queried.
   - For the check mentioned above.
- The net differences between the current and previous price updates for `XAU` and `WTI` are calculated independently, elevated to a 100% percentage scale, the result multiplied by Chainlink's Crypto Volatility Index, and the product of each set of operations (one for `XAU` and oe for `WTI`) are added together, and then combined to `basePrice`.
- `eETH`'s price can be lower than `ETH`'s if the price fluctuation of `XAU` and/or `WTI` is negative between Chainlink updates.
     - Since this is raw PoC implementation, the formula for calculating `eETH` can be improved to only allow positive fluctuations. 

This gives us an asset that follows `ETH` trend, but it diverges towards its own price action due to the influence of `XAU` and `WTI`. 

## Technical specifications
- It's an extension of Ozel v1's Diamond pattern ([EIP-2535](https://eips.ethereum.org/EIPS/eip-2535)), in the sense that it's an upgrade done through the `diamondCut()` function described in the specs of the EIP.
- It uses the following Chainlink price feeds (on Arbitrum One) for calculating `eETH`:
    - ETH/USD: [0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612](https://arbiscan.io/address/0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612).
    - XAU/USD: [0x1F954Dc24a49708C26E0C1777f16750B5C6d5a2c](https://arbiscan.io/address/0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612).
    - WTI/USD: [0x594b919AD828e693B935705c3F816221729E7AE8](https://arbiscan.io/address/0x594b919AD828e693B935705c3F816221729E7AE8).
         - The actual feeds from above are not used themselves since the project is not live in Arbitrum mainnet, but it does use mocks that comform to the `AggregatorV3Interface` specs, which is the interface used by Chainlink's price feeds.
    - Volatility Index: [0xbcD8bEA7831f392bb019ef3a672CC15866004536](https://arbiscan.io/address/0xbcD8bEA7831f392bb019ef3a672CC15866004536).
- It uses Uniswap's TWAP spot oracle of the ETH/USD 0.05% for the calculation of `basePrice`.
- [Permit2](https://docs.uniswap.org/contracts/permit2/overview) is used to be able to mint new `eETH` tokens without an approval.
- It also has the possibility to add more assets/prices to the calculation of `eETH` due to the upgradeability of the system.

## Running the PoC
If you want run the Foundry test that shows the values for `eETH` as an index and the sub-values that it's made of:
- Pull the proper Docker image with `docker pull dnyrm/energy_eth_logs:0.0.2`.
- Run the Docker container with `docker run -it dnyrm/energy_eth_logs:0.0.2`.
- The test that's ran is `test_logPrices()` from the file `EnergyETH.t.sol`.
- This would be the output:
  

<img width="305" alt="Screenshot 2024-03-08 at 7 11 39 PM" src="https://github.com/cdgmachado0/ozel-vN/assets/59457858/4b416964-3d05-4a5b-b731-39b4f1d562df">

## Running the tests
If you want to run the basic tests the prove that the system is functional, do these:
- Pull the proper Docker image with `docker pull dnyrm/energy_eth_tests:0.0.1`.
- Run the Docker container with `docker run -it dnyrm/energy_eth_tests:0.0.1`.
