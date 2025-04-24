require('dotenv').config();
require("@nomicfoundation/hardhat-toolbox");
require('hardhat-contract-sizer');
require("hardhat-gas-reporter");
require('@openzeppelin/hardhat-upgrades');
require('hardhat-abi-exporter');
require('solidity-docgen');
// require("@truffle/dashboard-hardhat-plugin");
require("@solidstate/hardhat-bytecode-exporter");
require("@nomicfoundation/hardhat-verify");


module.exports = {
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },

  solidity: {
    version: "0.8.27",
    settings: {
      // viaIR: true,
      optimizer: {
        enabled: true,
        runs: 1000,
        details: {
          yul: true
        }
      },
      viaIR: false
    }
  },

  networks: {
    hardhat: {
    },
    dashboard: {
      url: "http://localhost:24012/rpc",
    },
    polygonAmoy: {
      chainId: 80002,
      url: `${process.env.AMOY_PROVIDER}`,
      accounts: [`${process.env.AMOY_PRIVATE_KEY}`],
      // account: [process.env.AMOY_PRIVATE_KEY.toString()],
      confirmations: 2,
      skipDryRun: true,
      gasPrice: 100000000000,
      urls: {
        apiURL: "https://api-amoy.polygonscan.com/api",
        browserURL: "https://amoy.polygonscan.com",
      },
    },
    polygonMain: {
      chainId: 137,
      url: `${process.env.POLYGON_PROVIDER}`,
      accounts: [`${process.env.POLYGON_PK_FACTORY_OWNER}`],
      confirmations: 2,
      skipDryRun: true,
    },
  }, 

  mocha: {
    timeout: 40000
  },

  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
  },

  gasReporter: {
    enabled: true,
    coinmarketcap: `${process.env.CMC_API_KEY}`,
    currency: 'EUR',
    L1: "polygon",
    L1Etherscan: `${process.env.POLYGONSCAN_KEY}`,
  },

  docgen: {
    sourcesDir: 'contracts',
    outputDir: 'documentation',
    templates: 'templates',
    pages: 'files',
    clear: true,
    runOnCompile: true,
  },

  etherscan: {
    apiKey: {
      goerli: process.env.ETHERSCAN_KEY,
      polygonAmoy: process.env.POLYGONSCAN_KEY,
      polygonMain: process.env.POLYGONSCAN_KEY,
    } 
  },

  abiExporter: [
    {
      path: './abi/json',
      format: "json",
      runOnCompile: true,
      clear: true,
    },
    {
      path: './abi/minimal',
      format: "minimal",
      runOnCompile: true,
      clear: true,
    },
    {
      path: './abi/fullName',
      format: "fullName",
      runOnCompile: true,
      clear: true,
    },
  ],

  bytecodeExporter: {
    path: './bytecode',
    runOnCompile: true,
    clear: true,
  },

  sourcify: {
    enabled: false,
  },

};
