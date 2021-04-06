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

  function enter() public override payable nonReentrant returns (bool) {
    require (msg.value == ticketPrice, "wrong amount of tokens");

    uint toPot = beforeEachEnter();
    _enter(toPot);

    return true;
  }

  function getPaid() public override nonReentrant returns (bool) {
    require(debtToUser[_sender()] != 0, "you have no winnings to claim");

    beforeEachPayment();
    uint winnings = _safePay();
    payable(_sender()).transfer(winnings);

    return true;
  }

  /*
  + Hooks
  */

  function beforeEachEnter() internal returns (uint) {
    uint amountAfterFee = takeFantomFee(ticketPrice);
    return amountAfterFee;
  }

  function beforeEachPayment() internal returns (bool) { }

  /*
  + View Functions
  */

  function viewName() public view override returns (string memory) {
    return name;
  }

  function viewDrawFrequency() public view override returns (uint) {
    return drawFrequency;
  }

  function viewTicketPrice() public view override returns (uint) {
    return ticketPrice;
  }

  function viewWinChance() public view override returns (uint) {
    return (winChance);
  }

  function viewCurrentLottery() public view override returns (uint) {
    return currentLotto;
  }

  function viewTicketHolders(bytes32 ticketID) public view override returns (address[] memory) {
    return tickets[ticketID].owners;
  }

  function viewTicketNumber(bytes32 ticketID) public view override returns (uint) {
    return tickets[ticketID].ticketNumber;
  }

  function viewStartTime(uint lottoNumber) public view override returns (uint) {
    return lottos[lottoNumber].startTime;
  }

  function viewLastDrawTime(uint lottoNumber) public view override returns (uint) {
    return lottos[lottoNumber].lastDraw;
  }

  function viewTotalPot(uint lottoNumber) public view override returns (uint) {
    return lottos[lottoNumber].totalPot;
  }

  function viewWinningTicket(uint lottoNumber) public view override returns (bytes32) {
    return lottos[lottoNumber].winningTicket;
  }

  function viewUserTicketList(uint lottoNumber) public view override returns (bytes32[] memory) {
    return userTickets[lottoNumber][msg.sender];
  }

  function viewWinnings() public view override returns (uint) {
    return debtToUser[_sender()];
  }

  function readyToDraw() public view override returns (bool) {
    return (_timestamp() - lottos[currentLotto].lastDraw >= drawFrequency);
  }
}
