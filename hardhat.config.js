require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  gasReporter: {
    enabled: false,
    currency: 'CHF',
    gasPrice: 21
  },
  solidity: {
    compilers: [
      {
        version: "0.8.16"

      },
      {version: "0.5.6"},
      {version: "0.6.6"}
    ]
  },
  etherscan: {
    apiKey: {
      polygonMumbai: "RAC8SMQW7DEBWPCSEZEYYD3MTHHV9IATQV",
      sepolia: "CX7CYFYEH2CBM1NP1ZTUIEBB4BZCCFAR2B"
    }
  },
  networks: {
    hardhat: {
      chainId: 31337,
      forking: {
        url: "https://eth-sepolia.g.alchemy.com/v2/nBnCZQRffDvtFdAo-ajlq_PLaozbRF0v",
        blockNumber: 3161613
      }
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      forking: {
        url: "https://eth-mainnet.g.alchemy.com/v2/q-XcEiXre1I0WRwgny8MxxsJN_Tl-GpV",
      },
    },
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/nBnCZQRffDvtFdAo-ajlq_PLaozbRF0v",
      accounts: [ process.env.PRIVATE_KEY]
    },
    mumbai: {
      url: "https://polygon-mumbai.g.alchemy.com/v2/fCAXOPsf7ykMktUbte9eB1kDH4g6U_S0",
      accounts: [ process.env.PRIVATE_KEY]
    }
  }

};
