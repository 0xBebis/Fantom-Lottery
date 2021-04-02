pragma solidity 0.8.0;

interface IERC20Lottery {
  function draw() external returns (bytes32);
  function enter() external returns (bytes32);
  function getPaid() external returns (bool);

  function viewWinnings() external view returns (uint);
  function viewTicketNumber(bytes32 _ticketID) external view returns (uint);
  function viewTicketHolders(bytes32 _ticketID) external view returns (address[] memory);
  function viewTicketsByLotto(uint lottoNumber) external view returns (bytes32[] memory);
  function readyToDraw() external view returns (bool);
  function viewOdds() external view returns (uint);

  event newRound(uint lottoNumber);
  event newEntry(address entrant, bytes32 ticketID, uint totalPot);
  event newDraw(bool winnerSelected, bytes32 winningTicket);
  event newPayment(address user, uint amount);
}
