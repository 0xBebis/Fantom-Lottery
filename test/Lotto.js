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
  let addr3;
  let addr4;
  let addrs;

  beforeEach(async function () {
    Lotto = await ethers.getContractFactory("LottoHelper");
    [owner, addr1, addr2, addr3, addr4, ...addrs] = await ethers.getSigners();
    lottery = await Lotto.deploy();
    await lottery.startNewRound();
  });
//{ value: ethers.utils.parseEther("1") }
  describe("Starting a new lottery", function () {
    it("should start the lottery, then increment currentLotto", async function () {
      expect(await lottery.viewLottoNumber()).to.equal(1);
    });
  });

  describe("Entering the lottery", function () {
    it("should increment ticket counter", async function () {
      let i;
      for (i = 1; i <= 10; i++) {
        await lottery.enter({ value: ticketPrice });
      }
      expect(await lottery.viewTicketCount()).to.equal(10);
    });
    it("should add fantom to the total pot", async function () {
      let i;
      for (i = 1; i <= 10; i++) {
        await lottery.enter({ value: ticketPrice });
        expect(await lottery.viewPot()).to.equal(ethers.utils.parseEther(`${i}`));
      }
    });
    it("should create a ticketID and save it to the sender account", async function () {
      let i;
      for (i = 0; i < 10; i++) {
        await lottery.connect(addr1).enter({ value: ticketPrice });
      }
      let ticketIDs = await lottery.connect(addr1).viewTicketsByLotto(1);
      expect(ticketIDs.length).to.equal(10);
    });
  });
  describe("drawing a ticket", function () {
    it("should update lastDraw to the current timestamp", async function () {
      const initialLast = await lottery.viewLast();
      await lottery.draw();
      const newLast = await lottery.viewLast();
      expect(newLast).to.not.equal(initialLast);
    });
    it("should update the current draw variable, or set to 0 if someone wins", async function () {
      let i;
      for (i = 1; i <= 100; i++) {
        await lottery.enter({ value: ticketPrice });
        await lottery.draw();
        if (await lottery.didSomeoneWin() == true) {
          expect(await lottery.viewCurrentDraw()).to.equal(0);
          console.log(await lottery.viewWinner());
          break;
        } else {
          expect(await lottery.viewCurrentDraw()).to.equal(i);
          console.log(await lottery.viewWinner());
        }
      }
    });
    it("should distribute the pot to each winner and take fee", async function () {
      let i;
      for (i = 1; i <= 10; i++) {
        await lottery.connect(addr1).enter({ value: ticketPrice });
        await lottery.connect(addr2).enter({ value: ticketPrice });
        await lottery.connect(addr3).enter({ value: ticketPrice });
        await lottery.connect(addr4).enter({ value: ticketPrice });
      }
        const totalPot = await lottery.viewPot();
        console.log(totalPot);
        await lottery.draw();
        const winningTicket = await lottery.viewWinner();
        console.log(winningTicket);
        const winners = await lottery.viewTicketHolders(winningTicket);
        console.log(winners);
        for (i=0; i<winners.length; i++) {
          console.log(await lottery.viewWinningsByAddress(winners[i]));
        }
        const rake = await lottery.viewWinnings();
        console.log(rake);
        expect(rake).to.equal(ethers.utils.parseEther(`${40*0.03}`));
        expect(totalPot).to.equal(ethers.utils.parseEther(`40`));
    })
  });
});