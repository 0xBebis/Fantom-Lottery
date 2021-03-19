const { expect } = require("chai");

describe("Lottery", function () {

  let Lotto;
  let lottery;
  let drawFrequency = 1;
  let ticketPrice = ethers.utils.parseEther("1");
  let name = "JB's Lottery";
  let recipient = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266';
  let modulus = 1;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    Lotto = await ethers.getContractFactory("LottoHelper");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    lottery = await Lotto.deploy();
  });
//{ value: ethers.utils.parseEther("1") }
  describe("Starting a new lottery", function () {
    it("should start the lottery, then increment currentLotto", async function () {
      await lottery.startNewRound();
      expect(await lottery.viewLottoNumber()).to.equal(1);
    });
  });

  describe("Entering the lottery", function () {
    it("should increment ticket counter", async function () {
      let i;
      for (i = 1; i <= 100; i++) {
        await lottery.enter({ value: ticketPrice });
      }
      expect(await lottery.viewTicketCount()).to.equal(100);
    });
    it("should add fantom to the total pot", async function () {
      let i;
      for (i = 1; i <= 100; i++) {
        await lottery.enter({ value: ticketPrice });
        expect(await lottery.viewPot()).to.equal(ethers.utils.parseEther(`${i}`));
      }
    });
  });
});
