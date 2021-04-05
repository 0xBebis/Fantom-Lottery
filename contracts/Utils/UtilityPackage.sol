/*
 + SPDX-License-Identifier: MIT
 + Made with <3 by your local Byte Masons
 + ByteMasons.dev | ByteMasons@protonmail.com
 + Source Code and Tests: https://github.com/Byte-Masons/fLotto-Core
*/

pragma solidity 0.8.0;

import "../Interfaces/IERC20.sol";

contract UtilityPackage {

  function _sender() internal view returns (address) {
    return msg.sender;
  }

  function _timestamp() internal view returns (uint) {
    return block.timestamp;
  }
}
