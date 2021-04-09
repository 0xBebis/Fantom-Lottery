/*
 + SPDX-License-Identifier: MIT
 + Made with <3 by your local Byte Masons
 + ByteMasons.dev | ByteMasons@protonmail.com
*/

pragma solidity 0.8.0;

import "../Interfaces/IERC20.sol";

contract Incentivized {

  uint public currentEpoch;

  //epochs can be implemented in your project in any fashion
  struct Incentive {
    address token;
    uint amount;
    uint startingEpoch;
    uint amountPerEpoch;
    uint lengthInEpochs;
    uint claimedThisEpoch;
    uint uniqueClaimants;
    bool isPaused;
  }

  mapping (uint => Incentive) public incentives;

  mapping (address => bool) public administrators;

  constructor () {
    administrators[msg.sender] = true;
  }
/*
  function createNewIncentiveStrategy(
    address _token,
    uint _amount,
    address _startingEpoch,
    address _amountPerEpoch,
    address _lengthInEpochs
  ) public
    returns (bool) {
    return true;
  }
*/
  function incentivize(address user) internal returns (bool) {
  }

  function approveAdministrator(address newAdmin) public returns (bool) {

  }


}
