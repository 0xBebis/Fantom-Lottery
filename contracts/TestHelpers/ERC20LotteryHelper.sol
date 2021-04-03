// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "../ERC20Lottery.sol";
import "../Interfaces/IERC20.sol";
import "./TestToken.sol";

contract ERC20LotteryHelper is ERC20Lottery {

  address ownr = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

  constructor() ERC20Lottery("ERC20 Lottery", 0, 1000000000000000000, 10, address(0), 30000000000000000, ownr) {
  }

  function updateTokenAddress(address _ad) public returns (bool) {
    tokenAddress = _ad;
    return true;
  }

  function checkRandomness() public view returns (uint[5] memory) {
    return [generateRandomNumber(), (generateRandomNumber() % 5),block.number, block.timestamp, ticketCounter];
  }

  function getTokenAddress() public view returns (address) {
    return tokenAddress;
  }

  function viewWinningsByAddress(address addr) public view returns (uint) {
    return debtToUser[addr];
  }

  function viewCurrentDraw() public view returns (uint) {
    return currentDraw;
  }

  function didSomeoneWin() public view returns (bool) {
    return !(lottos[currentLotto-1].winningTicket == bytes32(0));
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

  function viewLastPot() public view returns(uint) {
    return lottos[currentLotto-1].totalPot;
  }

  function viewWinner() public view returns(bytes32) {
    return lottos[currentLotto-1].winningTicket;
  }

  function viewFinished() public view returns(bool) {
    return lottos[currentLotto-1].finished;
  }

  function viewTicketCount() public view returns(uint) {
    return ticketCounter;
  }

  function viewLottoNumber() public view returns(uint) {
    return currentLotto;
  }
}
