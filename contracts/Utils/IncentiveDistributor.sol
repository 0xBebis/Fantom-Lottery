/*
 + SPDX-License-Identifier: MIT
 + Made with <3 by your local Byte Masons
 + ByteMasons.dev | ByteMasons@protonmail.com
*/

pragma solidity 0.8.0;

import "../Interfaces/IERC20.sol";
import "./UtilityPackage.sol";

contract IncentiveDistributor is UtilityPackage {

  uint currentEpoch;
  //epochs can be implemented in your project in any fashion
  struct IncentiveStrategy {
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

  modifier onlyAdmin() {
    require(administrators[_sender()], "You are not an admin.");
    _;
  }

  constructor () {
    administrators[msg.sender] = true;
  }

  function createIncentiveStrategy(
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
    if (incentiveCheck(strategy)) {
      IERC20(incentives[strategy].token).transfer(msg.sender, incentives[strategy].amount);
      incentives[strategy].claimedThisEpoch++;
      return true;
    } else { return false; }
  }

  function incentiveCheck(uint _strategy) internal view returns (bool) {
    if (currentEpoch <= incentives[_strategy].startingEpoch &&
        !incentives[_strategy].isPaused &&
        currentEpoch <= (incentives[_strategy].startingEpoch + incentives[_strategy].lengthInEpochs) &&
        incentives[_strategy].claimedThisEpoch <= incentives[_strategy].claimsPerEpoch) {
          return true;
        } else { return false; }
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
