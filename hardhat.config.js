require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: "0.8.26",
  paths: {
    sources: "./contracts", // Default source directory for Solidity files
    tests: "./test", // Default directory for tests
    cache: "./cache", // Cache for faster recompilation
    artifacts: "./artifacts", // Compiled contract output
  },
  networks: {
    hardhat: {
      chainId: 1337, // Local blockchain
    },
  },
};
