// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;



interface ITri { 
  function exchange(
    uint256 i,
    uint256 j,
    uint256 dx,
    uint256 min_dy,
    bool use_eth
  ) external payable;

  function get_virtual_price() external view returns (uint256);
  function get_dy(uint i, uint j, uint dx) external view returns(uint256);
  function add_liquidity(uint256[3] calldata amounts, uint256 min_mint_amount) external;
  function calc_token_amount(uint256[3] calldata amounts, bool deposit) external view returns(uint256);
  function remove_liquidity_one_coin(uint256 token_amount, uint256 i, uint256 min_amount) external;
  function calc_withdraw_one_coin(uint256 token_amount, uint256 i) external view returns(uint256);
  function balanceOf(address account) external view returns (uint256);
}