/*
 + SPDX-License-Identifier: MIT
 + Made with <3 by your local Byte Masons
 + ByteMasons.dev | ByteMasons@protonmail.com
*/

pragma solidity 0.8.0;

import "../Interfaces/IERC20.sol";

contract Incentivized {

  mapping (address => uint) public incentiveTokens;
  mapping (address => uint) public incentiveAmounts;
  mapping (address => uint) public incentivesPerEpoch;
  mapping (address => uint) public incentivesThisEpoch;

  mapping (address => bool) public administrators;

  address public activeTokens;

  constructor () {
    administrators[msg.sender] = true;
  }

  function fund(
    uint amount,
    address incentiveToken,
    address tokensPerPayout,
    address availableIncentivesPerEpoch,
    address tokenIndex
  ) public returns (bool) {
    require(administrators[msg.sender], "you are not authorized to fund this contract")
    IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
    incentiveTokens[incentiveToken] += amount;
    incentiveAmounts[incentiveToken] = tokensPerPayout;
    incentivesPerLottery[incentiveToken] = incentivesPerLottery;
    availableTokens.push(incentiveToken);
    return true;
  }

  function incentivize(address user) internal returns (bool) {

    for (i=0; i<10; i++) {
      IERC20(activeTokens[i]).transfer(user, incentiveAmounts[activeTokens[i]]);
    }
  }

  function approveAdministrator(address newAdmin) public returns (bool) {

  }


}
