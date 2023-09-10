const path = require("path");
const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();

const { MNEMONIC_TEST, MNEMONIC_PROD, INFURA_API_KEY_SEPOLIA, INFURA_API_KEY_POLYGON  } = process.env;

module.exports = {

  networks: {
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: '7545',            // Standard Ethereum port (default: none)
      network_id: "5777",       // Any network (default: none)
    },
    sepolia: {
      provider: () =>
      new HDWalletProvider({
        mnemonic:       {phrase: `${MNEMONIC_TEST}`},
        providerOrUrl:  `${INFURA_API_KEY_SEPOLIA}`,
        pollingInterval: 30000,
        gasPrice: 470000000000,
      }),
      network_id: 11155111
    },
    // polygon: {
    //   provider: () =>
    //   new HDWalletProvider({
    //     mnemonic:       {phrase: `${MNEMONIC_PROD}`},
    //     providerOrUrl:  `${INFURA_API_KEY_POLYGON}`,
    //     gasPrice: 470000000000,
    //   }),
    //   network_id: 137
    // },
    polygonmumbai: {
      provider: () => new HDWalletProvider(`${MNEMONIC_TEST}`, `https://rpc-mumbai.maticvigil.com`),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    polygon: {
      provider: () => new HDWalletProvider(`${MNEMONIC_PROD}`, `${INFURA_API_KEY_POLYGON}`),
      network_id: 137,
      // confirmations: 2,
      // timeoutBlocks: 200,
      // skipDryRun: true,
      gasPrice: 470000000000
    },
  },
  mocha: {},
  compilers: {
    solc: {
      version: "0.8.19",
    }
  },
};
