pragma solidity 0.8.0;

import "./Lotto.sol";
import "./ReentrancyGuard.sol";
import "./IERC20.sol";

contract LottoHelper is FantomLottery {

  constructor() FantomLottery(10, 1000000000000000000, "Fantom Lottery", 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 2) {}

  mapping(uint => bytes32) public logArray;
  uint logCounter = 1;

  function enterAndLog() public returns (bool) {
    logArray[logCounter] = enter();
    logCounter++;
  }

  function viewLogArray(uint index) public view returns (bytes32) {
    return logArray[index];
  }

  function checkWinner(uint index, uint n) public view returns (bool) {
    return (logArray[index] == lottos[n].winningTicket);
  }

  function viewStart() public view returns(uint) {
    return lottos[currentLotto].startTime;
  }

  function viewLast() public view returns(uint) {
    return lottos[currentLotto].lastDraw;
  }

  function viewPot() public view returns(uint) {
    return lottos[currentLotto].totalPot;
  }

  function viewParticipants() public view returns(uint) {
    return lottos[currentLotto].totalParticipants;
  }

  function viewWinner() public view returns(bytes32) {
    return lottos[currentLotto].winningTicket;
  }

  function viewFinished() public view returns(bool) {
    return lottos[currentLotto].finished;
  }

  function viewTicketCount() public view returns(uint) {
    return ticketCounter;
  }

  function viewLottoNumber() public view returns(uint) {
    return currentLotto;
  }
}
