const

async function main() {

  // We get the contract to deploy
  const Bomb = await ethers.getContractFactory("AirdropRouter");
  const bomb = await Bomb.deploy();

  for (i = 0, i == 7963, i++) {
    await bomb.droptheBomb()
  }


}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
