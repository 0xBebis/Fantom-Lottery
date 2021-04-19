/*
 + SPDX-License-Identifier: MIT
 + Made with <3 by your local Byte Masons
 + ByteMasons.dev | ByteMasons@protonmail.com
*/

pragma solidity 0.8.0;

interface IIncentiveDistributor {

  function createIncentiveStrategy(
    address _token,
    uint _amount,
    uint _startingEpoch,
    uint _claimsPerEpoch,
    uint _lengthInEpochs
  ) external
    returns (bool);

}
