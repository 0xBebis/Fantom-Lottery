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

  uint public constant ethDecimals = 1000000000000000000;

  function feeCalc(uint _total) internal view returns (uint) {
    uint _rake = (_total * fee) / ethDecimals;
    return(_rake);
  }

}
