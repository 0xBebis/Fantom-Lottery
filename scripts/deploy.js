async function main() {

  let drawFrequency = 1;
  let ticketPrice = 1;
  let name = "JB's Lottery";
  let recipient = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266';
  let modulus = 1;
  // We get the contract to deploy
  const Lotto = await ethers.getContractFactory("lotto");
  const lottery = await Lotto.deploy(drawFrequency, ticketPrice, name, recipient, modulus);

  console.log("lotto deployed to:", lottery.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
