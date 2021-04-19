/*
 + SPDX-License-Identifier: MIT
 + Made with <3 by your local Byte Masons
 + ByteMasons.dev | ByteMasons@protonmail.com
*/

pragma solidity 0.8.0;

import "../Interfaces/IERC20.sol";
import "../Interfaces/IIncentiveDistributor.sol";
import "./UtilityPackage.sol";

contract IncentiveDistributor is IIncentiveDistributor, UtilityPackage {

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
  mapping (uint => IncentiveStrategy) public strategies;
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
    override
    returns (bool) {
    IERC20(_token).transferFrom(msg.sender, address(this), _amount);
    strategies[incentiveCounter] = IncentiveStrategy(_token, _amount, _startingEpoch, _claimsPerEpoch, 0, _lengthInEpochs, false);
    incentiveCounter++;
    return true;
  }

  //try to pare down all the requires
  function incentivize(uint strategy) internal returns (bool) {
    if (incentiveCheck(strategy)) {
      IERC20(strategies[strategy].token).transfer(msg.sender, strategies[strategy].amount);
      strategies[strategy].claimedThisEpoch++;
      return true;
    } else { return false; }
  }

  function incentiveCheck(uint _strategy) internal view returns (bool) {
    if (currentEpoch <= strategies[_strategy].startingEpoch &&
        !strategies[_strategy].isPaused &&
        currentEpoch <= (strategies[_strategy].startingEpoch + strategies[_strategy].lengthInEpochs) &&
        strategies[_strategy].claimedThisEpoch <= strategies[_strategy].claimsPerEpoch) {
          return true;
        } else { return false; }
  }

  function pauseStrategy(uint strategy) public returns (bool) {
    require(administrators[msg.sender], "not an admin");
    strategies[strategy].isPaused = true;
    return true;
  }

  function approveAdministrator(address newAdmin) public returns (bool) {
    require(administrators[msg.sender], "not an admin");
    administrators[newAdmin] = true;
    return true;
  }
}
