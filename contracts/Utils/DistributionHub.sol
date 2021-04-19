/*
 + SPDX-License-Identifier: MIT
 + Made with <3 by your local Byte Masons
 + ByteMasons.dev | ByteMasons@protonmail.com
*/

pragma solidity 0.8.0;

import "../Interfaces/IIncentiveDistributor.sol";

contract DistributionHub {

  uint public totalStaked;
  uint public lockTime;

  struct User {
    uint weight;
    uint staged;
    uint stagingTime;
  }

  struct Proposal {
    address targetContract;
    uint amount;
    uint startingEpoch;
    uint claimsPerEpoch;
    uint lengthInEpochs;
    uint approvalVotes;
    bool approved;
  }

  struct Vote {
    uint time;
    uint weight;
  }

  mapping (address => bool) public approvedProposers;
  mapping (bytes32 => IncentiveProposal) public proposals;
  mapping (bytes32 => mapping (address => Vote)) public votes;

  function proposeStrategy(
    address _targetContract,
    uint _amount,
    uint _startingEpoch,
    uint _claimsPerEpoch,
    uint _lengthInEpochs,
  ) public returns (bool) { }

  function executeStrategy(bytes32 Proposal) public returns (bool) {
    require(IERC20(_token).balanceOf() >= amount, "insufficient token balance");
    require(proposals[proposalId].approved, "this proposal has not received approval");
    proposals[proposalId].approved = false;

    Incentiveproposal memory strategy = proposals[proposalId];
    IERC20(_token)._approve(address(this), strategy.targetContract, strategy.amount);
    IDistributor distributor = IDistributor(_targetContract);

    distributor.createIncentiveStrategy(
      address(this),
      strategy.amount,
      strategy.startingEpoch,
      strategy.claimsPerEpoch,
      strategy.lengthInEpochs
    );

    return true;
  }

  function generateProposalId() internal returns (bytes32) { }

  function rewardVoter() internal returns (bool) { }

  function approveProposer() internal returns (bool) { }

  function removeProposer() internal returns (bool) { }

  function viewVoteTime() internal returns (uint) { }

  function viewVoteWeight() internal returns (uint) { }



}
