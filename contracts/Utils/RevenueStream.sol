/*
 + SPDX-License-Identifier: MIT
 + Made with <3 by your local Byte Masons
 + ByteMasons.dev | ByteMasons@protonmail.com
 + Source Code and Tests: https://github.com/Byte-Masons/fLotto-Core
*/

import "../Interfaces/IERC20.sol";

pragma solidity 0.8.0;
//todo implement recipient change
contract RevenueStream {

  uint public fee;
  address public feeRecipient;
  address public self = address(this);

  uint public fantomDebtToRecipient;
  mapping(address => uint) public ERC20DebtToRecipient;

  uint public constant ethDecimals = 1000000000000000000;

  function feeCalc(uint _total) internal view returns (uint) {
    uint _rake = (_total * fee) / ethDecimals;
    return(_rake);
  }

  function takeFantomFee(uint _total) internal returns (uint) {
    uint rake = feeCalc(_total);
    fantomDebtToRecipient += rake;
    uint leftover = _total - rake;
    return leftover;
  }

  function takeERC20Fee(address _tokenToTake, uint _total) internal returns (uint) {
    uint rake = feeCalc(_total);
    ERC20DebtToRecipient[_tokenToTake] += rake;
    uint leftover = _total - rake;
    return leftover;
  }

  function withdrawERC20(address ERC20Address) public returns (bool) {
    require(msg.sender == feeRecipient, "You are not the fee recipient");
    require(ERC20DebtToRecipient[ERC20Address] > 0, "you have nothing to claim");

    uint payment = ERC20DebtToRecipient[ERC20Address];
    ERC20DebtToRecipient[ERC20Address] = 0;
    IERC20(ERC20Address).transfer(feeRecipient, payment);

    return true;
  }

  function withdrawFantom() public returns (bool) {
    require(msg.sender == feeRecipient, "You are not the fee recipient");
    require(fantomDebtToRecipient > 0, "you have nothing to claim");

    uint payment = fantomDebtToRecipient;
    fantomDebtToRecipient = 0;
    payable(msg.sender).transfer(payment);

    return true;
  }

  function changeRecipient(address newRecipient) public returns (bool) {
    require(msg.sender == feeRecipient, "You are not the fee recipient");
    feeRecipient = newRecipient;
    return true;
  }

  function viewFantomCollected() public view returns (uint) {
    return fantomDebtToRecipient;
  }

  function viewTokensCollected(address _token) public view returns (uint) {
    return ERC20DebtToRecipient[_token];
  }
}
