/*
 + SPDX-License-Identifier: MIT
 + Made with <3 by your local Byte Masons
 + ByteMasons.dev | ByteMasons@protonmail.com
 + Source Code and Tests: https://github.com/Byte-Masons/fLotto-Core
*/

pragma solidity 0.8.0;

interface IFantomLottery {
  function enter() external payable returns (bool);
  function getPaid() external returns (bool);

  function viewName() external view returns (string memory);
  function viewDrawFrequency() external view returns (uint);
  function viewTicketPrice() external view returns (uint);
  function viewWinChance() external view returns (uint);
  function viewCurrentLottery() external view returns (uint);
  function viewTicketCount() external view returns (uint);
  function viewCurrentDraw() external view returns (uint);
  function viewFee() external view returns (uint);
  function viewFeeRecipient() external view returns (address);
  function viewTicketHolders(bytes32 ticketID) external view returns (address[] memory);
  function viewTicketNumber(bytes32 ticketID) external view returns (uint);
  function viewStartTime(uint lottoNumber) external view returns (uint);
  function viewLastDrawTime(uint lottoNumber) external view returns (uint);
  function viewTotalPot(uint lottoNumber) external view returns (uint);
  function isFinished(uint lottoNumber) external view returns (bool);
  function viewWinningTicket(uint lottoNumber) external view returns (bytes32);
  function viewUserTicketList(uint lottoNumber) external view returns (bytes32[] memory);
  function viewLastEntry(uint lottoNumber) external view returns (bytes32);
  function viewWinnings() external view returns (uint);
  //function readyToDraw() external view returns (bool);
}
