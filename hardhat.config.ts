import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import '@nomiclabs/hardhat-etherscan';
import { config as dotenv_config } from 'dotenv';
dotenv_config();
import 'hardhat-gas-reporter';

const config: HardhatUserConfig = {
  solidity: '0.8.16',
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      forking: {
        url: 'https://mainnet.aurora.dev',
      },
    },
    aurora: {
      url: process.env.AURORA_URL,
      chainId: 1313161554,
      accounts: JSON.parse(process.env.PRIVATE_KEYS || '[]'),
      gas: 12000000,
      blockGasLimit: 0x1fffffffffffff,
    },
  },
  etherscan: {
    apiKey: {
      aurora: process.env.AURORASCAN_API_KEY || '',
    },
  },
  // gasReporter: {
  //   enabled: true,
  // },
};

export default config;
