const { expect } = require("chai");

describe("Lottery", function () {

  let Lotto;
  let lottery;
  let ticketPrice = ethers.utils.parseEther("1");
  let bigFee = ethers.utils.parseEther('0.5');
  let littleFee = ethers.utils.parseEther('0.05');
  let owner;
  let addr1;
  let addr2;
  let addr3;
  let addr4;
  let addrs;

  beforeEach(async function () {
    Lotto = await ethers.getContractFactory("FantomLottery");
    [owner, addr1, addr2, addr3, addr4, ...addrs] = await ethers.getSigners();
  });
//{ value: ethers.utils.parseEther("1") }
  describe("Starting a new lottery", function () {
    it("should initiate the lottery with proper name", async function () {
      lottery = await Lotto.deploy("bigmoneygetterLottery", 6, ticketPrice, 45, 0, owner.address);
      expect(await lottery.viewName()).to.equal("bigmoneygetterLottery");
    });
    it("should initiate the lottery with proper draw frequency", async function () {
      lottery = await Lotto.deploy("bigmoneygetterLottery", 6, ticketPrice, 45, 0, owner.address);
      expect(await lottery.viewDrawFrequency()).to.equal(6);
    });
    it("should initiate the lottery with proper ticket price", async function () {
      lottery = await Lotto.deploy("bigmoneygetterLottery", 6, ticketPrice, 45, 0, owner.address);
      expect(await lottery.viewTicketPrice()).to.equal(ticketPrice);
    });
    it("should initiate the lottery with proper win chance", async function () {
      lottery = await Lotto.deploy("bigmoneygetterLottery", 6, ticketPrice, 45, 0, owner.address);
      expect(await lottery.viewWinChance()).to.equal(45);
    });
    it("should initiate the lottery with 0 in the pot", async function () {
      lottery = await Lotto.deploy("bigmoneygetterLottery", 6, ticketPrice, 45, 0, owner.address);
      expect(await lottery.viewWinChance()).to.equal(45);
    });
    it("should initiate the lottery with proper win chance", async function () {
      lottery = await Lotto.deploy("bigmoneygetterLottery", 6, ticketPrice, 45, 0, owner.address);
      expect(await lottery.viewWinChance()).to.equal(45);
    });
    it("should initiate the lottery with proper fee", async function () {
      lottery = await Lotto.deploy("bigmoneygetterLottery", 6, ticketPrice, 45, 56, owner.address);
      expect(await lottery.viewFee()).to.equal(56);
    });
    it("should initiate the lottery with proper fee recipient", async function () {
      lottery = await Lotto.deploy("bigmoneygetterLottery", 6, ticketPrice, 45, 0, owner.address);
      expect(await lottery.viewFeeRecipient()).to.equal(owner.address);
    });
    it("should start the lottery, then increment currentLotto", async function () {
      lottery = await Lotto.deploy("Lottery", 0, 0, 1, 0, owner.address);
      expect(await lottery.viewCurrentLottery()).to.equal(1);
    });
    it("should start a new lotto when a winner is chosen", async function () {
      lottery = await Lotto.deploy("Lottery", 0, 0, 1, 0, owner.address);
      await lottery.enter();
      expect(await lottery.viewCurrentLottery()).to.equal(2);
    });
    it("should emit newRound when the lottery is won", async function () {
      lottery = await Lotto.deploy("Lottery", 0, 0, 1, 0, owner.address);
      expect(await lottery.enter()).to.emit(lottery, 'newRound').withArgs(2);
    });
  });
  describe("entering the lottery", function () {
    it("should accept payment", async function () {
      lottery = await Lotto.deploy("Lottery", 0, ticketPrice, 10000000, 0, owner.address);
      await lottery.enter({ value: ticketPrice });
      expect(await lottery.viewTotalPot(1)).to.equal(ticketPrice);
    });
    it("should increment total pot with the ticket price", async function () {
      lottery = await Lotto.deploy("Lottery", 0, ticketPrice, 100000000, 0, owner.address);
      await lottery.enter({ value: ticketPrice });
      expect(await lottery.viewTotalPot(1)).to.equal(ticketPrice);
    });
    it("should take fees if configured to do so", async function () {
      lottery = await Lotto.deploy("Lottery", 0, 100, 100000000, littleFee, owner.address);
      await lottery.enter({ value: 100 });
      expect(await lottery.viewTotalPot(1)).to.equal(95);
      await lottery.enter({ value: 100 });
      expect(await lottery.viewTotalPot(1)).to.equal(190);
    });
    it("should credit those fees to recipient's account", async function () {
      lottery = await Lotto.deploy("Lottery", 0, 100, 100000000, bigFee, owner.address);
      await lottery.enter({ value: 100 });
      expect(await lottery.viewFantomCollected()).to.equal(50);
      await lottery.enter({ value: 100 });
      expect(await lottery.viewFantomCollected()).to.equal(100);
    });
    it("should increment the ticket counter", async function () {
      lottery = await Lotto.deploy("Lottery", 0, 0, 1000000000, 0, owner.address);
      await lottery.enter();
      expect(await lottery.viewTicketCount()).to.equal(1);
      await lottery.enter();
      expect(await lottery.viewTicketCount()).to.equal(2);
    });
    it("should push the ticket ID onto user's ticket list", async function () {
      lottery = await Lotto.deploy("Lottery", 0, 0, 1000000000, 0, owner.address);
      await lottery.enter();
      let ticketArray = await lottery.viewUserTicketList(1);
      let lastEntry = await lottery.viewLastEntry(1);
      expect(ticketArray.length).to.equal(1);
      expect(ticketArray[0]).to.equal(lastEntry);
      await lottery.enter();
      ticketArray = await lottery.viewUserTicketList(1);
      lastEntry = await lottery.viewLastEntry(1);
      expect(ticketArray.length).to.equal(2);
      expect(ticketArray[1]).to.equal(lastEntry);
    });
    it("should draw when able after entry", async function () {
      lottery = await Lotto.deploy("Lottery", 0, 0, 1, 0, owner.address);
      expect(await lottery.enter()).to.emit(lottery, 'newDraw');
    });
    it("should emit a newEntry event", async function () {
      lottery = await Lotto.deploy("Lottery", 0, 0, 1, 0, owner.address);
      expect(await lottery.enter()).to.emit(lottery, 'newEntry');
    });
  });
  describe("drawing a ticket", function () {
    it("should update the last draw timestamp", async function () {
      lottery = await Lotto.deploy("Lottery", 0, 0, 10000000, 0, owner.address);
      const initialDrawTime = await lottery.viewStartTime(1);
      await lottery.enter();
      expect(initialDrawTime).to.not.equal(await lottery.viewLastDrawTime(1));
    });
    it("should increment the current draw if there's no winner", async function () {
      lottery = await Lotto.deploy("Lottery", 0, 0, 10000000, 0, owner.address);
      await lottery.enter();
      let drawNumber = await lottery.viewCurrentDraw();
      expect(drawNumber).to.equal(1);
      await lottery.enter();
      drawNumber = await lottery.viewCurrentDraw();
      expect(drawNumber).to.equal(2);
    });
    it("should update the lottery when there's a winner", async function () {
      lottery = await Lotto.deploy("Lottery", 0, 0, 1, 0, owner.address);
      await lottery.enter();
      const winner = await lottery.viewUserTicketList(1);
      expect(await lottery.viewWinningTicket(1)).to.equal(winner[0]);
    });
    it("should update the lottery when there's a winner", async function () {
      lottery = await Lotto.deploy("Lottery", 0, 0, 1, 0, owner.address);
      await lottery.enter();
      const winner = await lottery.viewUserTicketList(1);
      expect(await lottery.viewWinningTicket(1)).to.equal(winner[0]);
    });
  });
  describe("Starting a new game", function () {
    it("should update the current lottery", async function () {
      lottery = await Lotto.deploy("Lottery", 0, 0, 1, 0, owner.address);
      expect(await lottery.viewCurrentLottery()).to.equal(1);
      lottery.enter();
      expect(await lottery.viewCurrentLottery()).to.equal(2);
    });
    it("should update the ticket counter to 0", async function () {
      lottery = await Lotto.deploy("Lottery", 0, 0, 1, 0, owner.address);
      expect(await lottery.viewTicketCount()).to.equal(0);
      lottery.enter();
      expect(await lottery.viewTicketCount()).to.equal(0);
    });
    it("should update the current draw", async function () {
      lottery = await Lotto.deploy("Lottery", 0, 0, 1, 0, owner.address);
      expect(await lottery.viewCurrentDraw()).to.equal(0);
      lottery.enter();
      expect(await lottery.viewTicketCount()).to.equal(0);
    });
    it("should instantiate a new lottery and finish the last", async function () {
      lottery = await Lotto.deploy("Lottery", 0, ticketPrice, 1, 0, owner.address);
      let startTime = await lottery.viewStartTime(1);
      await lottery.enter({ value: ticketPrice });
      expect(await lottery.viewCurrentLottery()).to.equal(2);
      expect(await lottery.viewStartTime(2)).to.not.equal(startTime);
      expect(await lottery.viewTotalPot(2)).to.equal(0);
      expect(await lottery.isFinished(1)).to.equal(true);
      expect(await lottery.isFinished(2)).to.equal(false);
    });
  });
  describe("getting paid", function () {
    it("should allow you to claim", async function () {
      lottery = await Lotto.deploy("Lottery", 0, ticketPrice, 1, 0, owner.address);
      await lottery.enter({ value: ticketPrice });
      expect(await lottery.viewWinnings()).to.equal(ethers.utils.parseEther("1"));
      await expect(() => lottery.getPaid()).to.changeEtherBalance(owner, ticketPrice);
    });
  });
});
