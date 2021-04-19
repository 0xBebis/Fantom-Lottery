/*
 + SPDX-License-Identifier: MIT
 + Made with <3 by your local Byte Masons
 + ByteMasons.dev | ByteMasons@protonmail.com
*/

pragma solidity 0.8.0;

import "../Base/ERC20.sol";
import "../Interfaces/IERC20.sol";
import "../Interfaces/IIncentiveDistributor.sol";

contract DistributionHub is ERC20("GamerCoin", "GAME") {

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

  mapping (address => bool) public approvedProposers;
  mapping (bytes32 => Proposal) public proposals;
  mapping (bytes32 => mapping (address => uint)) public voteTimestamp;

  function proposeStrategy(
    address _targetContract,
    uint _amount,
    uint _startingEpoch,
    uint _claimsPerEpoch,
    uint _lengthInEpochs
  ) public returns (bool) { }

  function executeStrategy(bytes32 proposalId) public returns (bool) {
    require(proposals[proposalId].approved, "this proposal has not received approval");
    proposals[proposalId].approved = false;

    Proposal memory prop = proposals[proposalId];
    _mint(address(this), prop.amount);
    _approve(address(this), prop.targetContract, prop.amount);
    IIncentiveDistributor distributor = IIncentiveDistributor(prop.targetContract);

    distributor.createIncentiveStrategy(
      address(this),
      prop.amount,
      prop.startingEpoch,
      prop.claimsPerEpoch,
      prop.lengthInEpochs
    );

    return true;
  }

  function generateProposalId() internal returns (bytes32) { }

  function rewardVoter() internal returns (bool) { }

  function approveProposer() internal returns (bool) { }

  function removeProposer() internal returns (bool) { }

  function hasVoted() internal returns (bool) { }

  function voteTime() internal returns (bool) { }

  function viewTargetContract(bytes32 proposalId) public returns (bool) { }

}
