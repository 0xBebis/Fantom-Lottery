pragma solidity 0.8.0;

import {Lotto} from "./Lotto.sol";

interface ILottoFactory {

  function createLottery (
    uint drawFrequencyInHours,
    uint ticketPriceInTenths,
    string memory _name,
    address _feeRecipient
  )
    external
    returns (address);
}

contract LottoFactory is ILottoFactory {

  function createLottery (
    uint drawFrequencyInHours,
    uint ticketPriceInTenths,
    string memory _name,
    address _feeRecipient
  )
    public
    override
    returns (address) {
      require(drawFrequencyInHours <= 730, "draw frequency should be less than a month");
      require(ticketPriceInTenths >= 1, "tickets must have a cost");
      require (!isContract(_feeRecipient), "user accounts only");

      Lotto newLotto = new Lotto(drawFrequencyInHours, ticketPriceInTenths, _name, _feeRecipient);
      return address(newLotto);
  }

  function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
  }
}
