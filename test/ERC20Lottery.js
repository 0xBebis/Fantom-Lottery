const { expect } = require("chai");

describe("ERC20Lottery", function () {

  let Lotto;
  let TestToken;
  let lottery;
  let ttoken;
  let ticketPrice = ethers.utils.parseEther("1");
  let maxApproval = ethers.utils.parseEther("10000000000");
  let owner;
  let ownr = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  let addr1;
  let ad1 = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";
  let addr2;
  let ad2 = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC";
  let addr3;
  let ad3 = "0x90F79bf6EB2c4f870365E785982E1f101E93b906";
  let addr4;
  let ad4 = "0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65";
  let addrs;

  beforeEach(async function () {
    Lotto = await ethers.getContractFactory("ERC20LotteryHelper");
    TestToken = await ethers.getContractFactory("TestToken");
    [owner, addr1, addr2, addr3, addr4, ...addrs] = await ethers.getSigners();
    lottery = await Lotto.deploy();
    ttoken = await TestToken.deploy(ownr, ad1, ad2, ad3, ad4);
    const ttokenAddress = await ttoken.address;
    const lottoAddress = await lottery.address;
    await lottery.updateTokenAddress(ttokenAddress);
    await ttoken.approve(lottoAddress, maxApproval);
    await ttoken.connect(addr1).approve(lottoAddress, maxApproval);
    await ttoken.connect(addr2).approve(lottoAddress, maxApproval);
    await ttoken.connect(addr3).approve(lottoAddress, maxApproval);
    await ttoken.connect(addr4).approve(lottoAddress, maxApproval);
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
        await lottery.enter();
      }
      expect(await lottery.viewTicketCount()).to.equal(10);
    });
    it("should add fantom to the total pot", async function () {
      let i;
      for (i = 1; i <= 10; i++) {
        await lottery.enter();
        expect(await lottery.viewPot()).to.equal(ethers.utils.parseEther(`${i}`));
      }
    });
    it("should create a ticketID and save it to the sender account", async function () {
      let i;
      for (i = 0; i < 10; i++) {
        await lottery.connect(addr1).enter();
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
        await lottery.enter();
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
        await lottery.connect(addr1).enter();
        await lottery.connect(addr2).enter();
        await lottery.connect(addr3).enter();
        await lottery.connect(addr4).enter();
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
    });
    it("should allow the user to withdraw funds", async function () {
      let i;
      console.log("===========Running Lottery===========")
      for (i = 1; i <= 100; i++) {
        await lottery.connect(addr1).enter();
        await lottery.draw();
        if (await lottery.didSomeoneWin() == true) {
          const winner = await lottery.viewWinner();
          console.log(`Winner, out of ${i} draws: ${winner}`);
          break;
        }
      }
      console.log("=====================================")
      const firstBalance = await ttoken.balanceOf(ad1);
      console.log(`Initial Balance: ${firstBalance.toString()}`);
      const pot = (await lottery.viewLastPot())*0.97;
      const rake = (await lottery.viewLastPot())*0.03;
      console.log(`Pot minus rake: ${pot.toString()}`);
      const ownerDebt = await lottery.viewWinnings();
      const userDebt = await lottery.connect(addr1).viewWinnings();
      console.log(`User account balance: ${userDebt.toString()}`);
      console.log(`Fee recipient account balance: ${ownerDebt.toString()}`)

      const tx = await lottery.connect(addr1).getPaid();
      const receipt = await tx.wait();
      const gas = parseInt(receipt.gasUsed);
      console.log(`Gas used to get paid: ${gas.toString()}`);

      const newBalance = await ttoken.balanceOf(ad1);
      console.log(`New Balance: ${newBalance.toString()}`)
      expect(parseInt(newBalance)).to.equal(parseInt(firstBalance) + parseInt(pot));
    });
  });
});
