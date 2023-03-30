import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "@openzeppelin/hardhat-upgrades";

dotenv.config();

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: "0.8.4",
  networks: {
    BSCTestnet: {
      url: process.env.NODE_RPC_URL || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      // @ts-ignore
      networkCheckTimeout: 20000,
      skipDryRun: true,
      gas: 7000000,
      gasPrice: 10000000000,
      network_id: 97,
    },
    BSCMainnet: {
      url: process.env.NODE_RPC_URL || "",
      accounts:
          process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      // @ts-ignore
      networkCheckTimeout: 20000,
      skipDryRun: true,
      gas: 7000000,
      gasPrice: 10000000000,
      network_id: 56,
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.BSCSCAN_API_KEY,
  },
};

export default config;
