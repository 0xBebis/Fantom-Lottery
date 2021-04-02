/*
 + SPDX-License-Identifier: MIT
 + Made with <3 by your local Byte Masons
 + ByteMasons.dev | ByteMasons@protonmail.com
 + Source Code and Tests: https://github.com/Byte-Masons/fLotto-Core
*/

pragma solidity 0.8.0;

import "./Base/LotteryLogic.sol";
import "./Interfaces/IFantomLottery.sol";
import "./Interfaces/IERC20.sol";
import "./Utils/ReentrancyGuard.sol";

contract FantomLottery is IFantomLottery, BaseLottery, RevenueStream, ReentrancyGuard {

  constructor(string memory _name, uint _drawFrequency, uint _ticketPrice, uint _winChance, uint _fee, address _feeRecipient) {
    name = _name;
    drawFrequency = _drawFrequency;
    ticketPrice = _ticketPrice;
    winChance = _winChance;
    fee = _fee;
    feeRecipient = _feeRecipient;
    startNewRound();
  }

  function enter() public override payable nonReentrant returns (bytes32) {
    require (msg.value == ticketPrice, "Wrong amount.");
    require (lottos[currentLotto].finished == false, "a winner has already been selected. please start a new lottery.");

    uint payment = msg.value;

    ticketCounter++;
    lottos[currentLotto].totalPot += payment;
    bytes32 ticketID = createNewTicket();
    userTickets[currentLotto][_sender()].push(ticketID);

    emit newEntry(_sender(), ticketID, lottos[currentLotto].totalPot);
    return ticketID;
  }

  function draw() public override nonReentrant returns (bytes32) {
    require (readyToDraw(), "Not enough time elapsed from last draw");
    require (!lottos[currentLotto].finished, "current lottery is over. please start a new one.");
    lottos[currentLotto].lastDraw = _timestamp();
    bytes32 winner = selectWinningTicket();

    if (winner == bytes32(0)) {
      currentDraw++;
      emit newDraw(false, winner);
      return winner;
    } else {
      lottos[currentLotto].winningTicket = winner;
      finalAccounting();
      resetGame();
      emit newDraw(true, winner);
      return winner;
    }
  }

  function getPaid() public override nonReentrant returns (bool) {
    require(debtToUser[_sender()] != 0, "you have no winnings to claim");

    uint winnings = debtToUser[_sender()];
    debtToUser[_sender()] = 0;
    payable(_sender()).transfer(winnings);

    assert(debtToUser[_sender()] == 0);

    emit newPayment(_sender(), winnings);
    return true;
  }

  function startNewRound() internal returns (bool) {
    if(currentLotto > 0) {
      require(lottos[currentLotto].finished, "previous lottery has not finished");
    }
    currentLotto++;
    lottos[currentLotto] = Lottery(_timestamp(), _timestamp(), 0, bytes32(0), false);
    emit newRound(currentLotto);
    return true;
  }

  function resetGame() internal returns (bool) {
    currentDraw = 0;
    ticketCounter = 0;
    startNewRound();
    return true;
  }

  function readyToDraw() public view override returns (bool) {
    return (_timestamp() - lottos[currentLotto].lastDraw >= drawFrequency);
  }

  function viewWinnings() public view override returns (uint) {
    return debtToUser[_sender()];
  }

  function viewTicketNumber(bytes32 _ticketID) public view override returns (uint) {
    return tickets[_ticketID].ticketNumber;
  }

  function viewTicketHolders(bytes32 _ticketID) public view override returns (address[] memory) {
    return tickets[_ticketID].owners;
  }

  function viewTicketsByLotto(uint lottoNumber) public view override returns (bytes32[] memory) {
    return userTickets[lottoNumber][_sender()];
  }

  function viewOdds() public view override returns (uint) {
    return (winChance);
  }

  function beforeEachEnter() internal returns (bool) { }
  function beforeEachDraw() internal returns (bool) { }
}
