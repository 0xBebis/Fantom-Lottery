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

contract BaseLottery is UtilityPackage {

  string public name;
  address public admin;

  uint public drawFrequency;
  uint public ticketPrice;
  uint public winChance;

  uint public currentLotto;
  uint public currentDraw;
  uint public ticketCounter;

  bool public paused = false;
  uint public pauseTime;

  struct Ticket {
    address[] owners;
    uint ticketNumber;
  }

	mapping (uint => Lottery) lottos;
  mapping (bytes32 => Ticket) public tickets;
  mapping (uint => mapping(address => bytes32[])) public userTickets;
  mapping (address => uint) public debtToUser;

  event newRound(uint lottoNumber);
  event newEntry(address entrant, bytes32 ticketID, uint totalPot);
  event newDraw(bool winnerSelected, bytes32 winningTicket);
  event newPayment(address user, uint amount);

  function _startNewRound() internal returns (bool) {
    require(!paused, "Game is paused by administrator");
    currentLotto++;
    lottos[currentLotto] = Lottery(_timestamp(), _timestamp(), 0, bytes32(0), false);
    emit newRound(currentLotto);
    return true;
  }

  function _enter(uint _toPot) internal returns (bool) {
    require(!paused, "Game is paused by administrator");
    lottos[currentLotto].totalPot += _toPot;
    bytes32 _ticketID = createNewTicket();
    ticketCounter++;
    userTickets[currentLotto][_sender()].push(_ticketID);

    if (readyToDraw()) {
      _draw();
    }

    emit newEntry(_sender(), _ticketID, lottos[currentLotto].totalPot);
    return true;
  }

  function _draw() internal returns (bool) {
    lottos[currentLotto].lastDraw = _timestamp();
    bytes32 _winner = selectWinningTicket();

    if (_winner == bytes32(0)) {
      currentDraw++;
      emit newDraw(false, _winner);
      return false;
    } else {
      lottos[currentLotto].winningTicket = _winner;
      finalAccounting();
      resetGame();
      emit newDraw(true, _winner);
      return true;
    }
  }

  function resetGame() internal returns (bool) {
    currentDraw = 0;
    ticketCounter = 0;
    _startNewRound();
    return true;
  }

  function selectWinningTicket() internal view returns (bytes32) {
    uint winningNumber = generateTicketNumber();
    bytes32 winningID = generateTicketID(winningNumber);

    if (tickets[winningID].owners.length > 0) {
      return winningID;
    } else {
      return bytes32(0);
    }
  }
  //test that we can handle 12 winners
  function createNewTicket() internal returns (bytes32) {
    uint ticketNumber = generateTicketNumber();
    bytes32 _ticketID = generateTicketID(ticketNumber);

    if (tickets[_ticketID].owners.length > 0) {
      require(tickets[_ticketID].owners.length <= 12, "Sorry, invalid ticket number. Please try again.");
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
    safeUserDebtCalculation();
    return true;
  }
  //stress test the for loop
  function safeUserDebtCalculation() internal returns (bool) {
    bytes32 winningTicket = lottos[currentLotto].winningTicket;
    uint winnings = lottos[currentLotto].totalPot;

    uint winnerCount = tickets[winningTicket].owners.length;
    uint winningsPerUser = (winnings / winnerCount);

    address[] memory winners = tickets[winningTicket].owners;

    for (uint i = 0; i < winners.length; i++) {
      debtToUser[winners[i]] += winningsPerUser;
    }
    return true;
  }

  function _safePay() internal returns (uint) {
    uint _winnings = debtToUser[_sender()];
    debtToUser[_sender()] = 0;
    return _winnings;
  }

  function generateTicketNumber() internal view returns (uint) {
    uint _rando = generateRandomNumber();
    uint _ticketNumber = _rando % winChance;
    return _ticketNumber;
  }

  function generateTicketID(uint _ticketNumber) internal view returns (bytes32) {
    bytes32 _ticketID = keccak256(abi.encodePacked(currentLotto, _ticketNumber));
    return _ticketID;
  }

  function generateRandomNumber() internal view returns (uint) {
    return (uint(keccak256(abi.encodePacked(block.timestamp, block.number, ticketCounter))));
  }

  function pauseAndRefund() public returns (bool) {

  }

  function readyToDraw() public view returns (bool) {
    return (_timestamp() - lottos[currentLotto].lastDraw >= drawFrequency);
  }
}
