/*
 + SPDX-License-Identifier: MIT
 + Made with <3 by your local Byte Masons
 + ByteMasons.dev | ByteMasons@protonmail.com
*/

pragma solidity 0.8.0;

import "../Interfaces/IERC20.sol";

contract Incentivized {

  uint currentEpoch;
  //epochs can be implemented in your project in any fashion
  struct Incentive {
    address token;
    uint amount;
    uint startingEpoch;
    uint claimsPerEpoch;
    uint claimedThisEpoch;
    uint lengthInEpochs;
    bool isPaused;
  }

  uint public incentiveCounter;
  mapping (uint => Incentive) public incentives;
  mapping (address => bool) public administrators;

  constructor () {
    administrators[msg.sender] = true;
  }

  function createNewIncentiveStrategy(
    address _token,
    uint _amount,
    uint _startingEpoch,
    uint _claimsPerEpoch,
    uint _lengthInEpochs
  ) public
    returns (bool) {
    IERC20(_token).transferFrom(msg.sender, address(this), _amount);
    incentives[incentiveCounter] = Incentive(_token, _amount, _startingEpoch, _claimsPerEpoch, 0, _lengthInEpochs, false);
    incentiveCounter++;
    return true;
  }

  //try to pare down all the requires
  function incentivize(uint strategy) internal returns (bool) {
    Incentive memory strat = incentives[strategy];
    require(currentEpoch >= strat.startingEpoch, "not ready");
    require(!strat.isPaused, "incentives are paused");
    require(currentEpoch <= strat.startingEpoch + strat.lengthInEpochs, "too late");
    require(strat.claimedThisEpoch <= strat.claimsPerEpoch, "no rewards left");
    IERC20(strat.token).transfer(msg.sender, strat.amount);
    strat.claimedThisEpoch++;
    incentives[strategy] = strat;
    return true;
  }

  function pauseStrategy(uint strategy) public returns (bool) {
    require(administrators[msg.sender], "not an admin");
    incentives[strategy].isPaused = true;
    return true;
  }

  function approveAdministrator(address newAdmin) public returns (bool) {
    require(administrators[msg.sender], "not an admin");
    administrators[newAdmin] = true;
    return true;
  }
}
