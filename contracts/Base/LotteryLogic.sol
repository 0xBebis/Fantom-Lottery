/*
 + SPDX-License-Identifier: MIT
 + Made with <3 by your local Byte Masons
 + ByteMasons.dev | ByteMasons@protonmail.com
 + Source Code and Tests: https://github.com/Byte-Masons/fLotto-Core
*/

struct Lottery {
  uint startTime;
  uint lastDraw;

  uint totalPot;

  bytes32 winningTicket;
  bool finished;
}

pragma solidity 0.8.0;

import "../Utils/RevenueStream.sol";
import "../Utils/UtilityPackage.sol";

contract BaseLottery is RevenueStream, UtilityPackage {

  string public name;

  uint public drawFrequency;
  uint public ticketPrice;
  uint public winChance;

  uint public currentLotto;
  uint public currentDraw;
  uint public ticketCounter;

  struct Ticket {
    address[] owners;
    uint ticketNumber;
  }

	mapping (uint => Lottery) lottos;
  mapping (bytes32 => Ticket) public tickets;
  mapping (uint => mapping(address => bytes32[])) public userTickets;
  mapping (address => uint) public debtToUser;

  function selectWinningTicket() internal view returns (bytes32) {
    uint winningNumber = generateTicketNumber();
    bytes32 winningID = generateTicketID(winningNumber);

    if (tickets[winningID].owners.length > 0) {
      return winningID;
    } else {
      return bytes32(0);
    }
  }

  function createNewTicket() internal returns (bytes32) {
    uint ticketNumber = generateTicketNumber();
    bytes32 _ticketID = generateTicketID(ticketNumber);

    if (tickets[_ticketID].owners.length > 0) {
      tickets[_ticketID].owners.push(_sender());
      return _ticketID;
    } else {
      address[] memory newOwner = new address[](1);
      newOwner[0] = _sender();
      tickets[_ticketID] = Ticket(newOwner, ticketNumber);
      return _ticketID;
    }
  }

  function finalAccounting() internal returns (bool) {
    lottos[currentLotto].finished = true;
    bytes32 _winningTicket = lottos[currentLotto].winningTicket;
    address[] memory winners = tickets[_winningTicket].owners;

    uint _winnings = calculateWinnings();
    uint winningsPerUser = safeUserDebtCalculation(_winnings, _winningTicket);

    for (uint i = 0; i < winners.length; i++) {
      debtToUser[winners[i]] += winningsPerUser;
    }
    return true;
  }

  function safeUserDebtCalculation(uint winnings, bytes32 winningTicket) internal returns (uint) {
    uint winnerCount = tickets[winningTicket].owners.length;
    uint rake = lottos[currentLotto].totalPot - winnings;
    debtToUser[feeRecipient] += rake;
    uint _winningsPerUser = (winnings / winnerCount);
    return _winningsPerUser;
  }

  function generateTicketNumber() internal view returns (uint) {
    uint _rando = generateRandomNumber();
    uint _ticketNumber = _rando % winChance;
    return _ticketNumber;
  }

  function calculateWinnings() internal view returns (uint) {
    uint total = lottos[currentLotto].totalPot;
    uint _rake = feeCalc(total);
    uint _winnings = total - _rake;
    assert(_winnings < lottos[currentLotto].totalPot);
    return _winnings;
  }

  function generateTicketID(uint _ticketNumber) internal view returns (bytes32) {
    bytes32 _ticketID = keccak256(abi.encodePacked(currentLotto, currentDraw, _ticketNumber));
    return _ticketID;
  }

  function generateRandomNumber() internal view returns (uint) {
    return (uint(keccak256(abi.encodePacked(block.timestamp, block.number, ticketCounter))));
  }
}
