require("@nomiclabs/hardhat-waffle");

const { fantomKey } = require('./secrets.json');

task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
})

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
    },
    opera: {
      url: "https://rpcapi.fantom.network",
      accounts: [fantomKey]
    }
  },
  solidity: {
    version: "0.8.0",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 50000
  }
};
