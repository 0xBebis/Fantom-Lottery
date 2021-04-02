/*
 + SPDX-License-Identifier: MIT
 + Made with <3 by your local Byte Masons
 + ByteMasons.dev | ByteMasons@protonmail.com
*/

pragma solidity 0.8.0;

import "../Interfaces/IERC20.sol";

contract Incentivized {

  address public incentiveToken;
  uint public amountPerEntry;

  constructor(address _incentiveToken, uint _amountPerEntry) {
    incentiveToken = _incentiveToken;
    amountPerEntry = _amountPerEntry;
  }

  function fund(uint _amount) public returns (bool) {
    IERC20(incentiveToken).transferFrom(msg.sender, address(this), _amount);
  }

}
