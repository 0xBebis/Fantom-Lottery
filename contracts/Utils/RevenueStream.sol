/*
 + SPDX-License-Identifier: MIT
 + Made with <3 by your local Byte Masons
 + ByteMasons.dev | ByteMasons@protonmail.com
 + Source Code and Tests: https://github.com/Byte-Masons/fLotto-Core
*/

pragma solidity 0.8.0;

contract RevenueStream {

  uint public fee;
  address public feeRecipient;

  uint public fantomDebtToRecipient;
  mapping(address => uint) public ERC20DebtToRecipient;


  uint public constant ethDecimals = 1000000000000000000;

  function feeCalc(uint _total) internal view returns (uint) {
    uint _rake = (_total * fee) / ethDecimals;
    return(_rake);
  }

  function takeFee(uint _total) internal returns (uint) {
    uint rake = feecalc(_total);
    debtToRecipient += rake;
    uint leftover = _total - rake;
    return leftover;
  }

  function takeERC20Fee(uint _total, uint _address) internal returns (uint) {
    uint rake = feecalc(_total);
    ERC20DebtToRecipient[address] += rake;
    uint leftover = _total - rake;
    return leftover;
  }

  function withdrawFees(uint ERC20Address) public returns (bool) {
    require(msg.sender == feeRecipient, "You are not the fee recipient");
    require(IERC20(ERC20Address).balanceOf(address(this)) > 0, "No tokens of that type to pay out");

    if (ERC20DebtToRecipient[ERC20Address] > 0) {
      ERC20DebtToRecipient[ERC20Address] = 0;
      IERC20(ERC20Address).transfer(feeRecipient, ERC20DebtToRecipient[ERC20Address]);
    }

    if (fantomDebtToRecipient > 0) {
      fantomDebtToRecipient = 0;
      payable(_sender()).transfer(fantomDebtToRecipient);
    }
    return true;
  }


}
