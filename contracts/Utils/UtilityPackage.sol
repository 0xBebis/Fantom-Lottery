/*
 + SPDX-License-Identifier: MIT
 + Made with <3 by your local Byte Masons
 + ByteMasons.dev | ByteMasons@protonmail.com
 + Source Code and Tests: https://github.com/Byte-Masons/fLotto-Core
*/

pragma solidity 0.8.0;

import "../Interfaces/IERC20.sol";

contract UtilityPackage {

  address public sweeper;

  constructor() {
    sweeper = _sender();
  }

  function _sender() internal view returns (address) {
    return msg.sender;
  }

  function _timestamp() internal view returns (uint) {
    return block.timestamp;
  }

  function sweep(address tokenToSweep) public returns (bool) {
    require(_sender() == sweeper, "must be the sweeper");
    uint tokenBalance = IERC20(tokenToSweep).balanceOf(address(this));
    if (tokenBalance > 0) {
      IERC20(tokenToSweep).transfer(sweeper, tokenBalance);
    }
    return true;
  }

  function changeSweeper(address newSweeper) public returns (bool) {
    require(_sender() == sweeper, "Only the sweeper can assign a replacement");
    sweeper = newSweeper;
    return true;
  }

}
