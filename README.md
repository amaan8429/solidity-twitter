## Solidity Twitter

A decentralized Twitter-like application built on Ethereum using Solidity. This project implements basic functionalities for creating posts, liking tweets, and interacting with smart contracts in a Web3 environment. It includes moderation features and demonstrates smart contract deployment and interaction.

### Features

- **Post Tweets**: Users can create and publish tweets.
- **Like Tweets**: Users can like tweets, adding to the community interaction.
- **Moderation**: Tweets can be flagged for moderation, ensuring content quality.
- **On-Chain Data**: All tweets and interactions are stored on the blockchain for transparency and immutability.

### Tech Stack

- **Solidity**: For smart contract development.
- **Hardhat**: Development environment for compiling, testing, and deploying contracts.
- **Ethers.js**: Interact with Ethereum in JavaScript.
- **OpenZeppelin**: Reusable smart contract components (e.g., for counters).

### Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd solidity-twitter
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Compile the smart contracts:

   ```bash
   npx hardhat compile
   ```

4. Run tests:

   ```bash
   npx hardhat test
   ```

5. Deploy the contracts to a test network:
   ```bash
   npx hardhat run scripts/deploy.js --network <network-name>
   ```

### License

This project is licensed under the MIT License.

---

This should give an overview of what the project is about, its functionality, and how to get it running!
