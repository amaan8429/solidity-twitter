import { expect } from "chai";
import { ethers } from "hardhat";

describe("Twitter and Profile Contracts", function () {
  let Profile, profile, Twitter, twitter, owner, user1, user2, moderator;

  beforeEach(async function () {
    // Deploy Profile contract
    Profile = await ethers.getContractFactory("Profile");
    profile = await Profile.deploy();
    await profile.deployed();

    // Deploy Twitter contract with Profile contract address
    Twitter = await ethers.getContractFactory("AdvancedTwitterWithModeration");
    twitter = await Twitter.deploy(profile.address);
    await twitter.deployed();

    // Get accounts
    [owner, user1, user2, moderator] = await ethers.getSigners();
  });

  describe("Profile Contract", function () {
    it("should allow users to set and get profiles", async function () {
      await profile.connect(user1).setProfile("User1", "Hello, I'm User1!");
      const profileData = await profile.getProfile(user1.address);

      expect(profileData.displayName).to.equal("User1");
      expect(profileData.bio).to.equal("Hello, I'm User1!");
    });
  });

  describe("AdvancedTwitterWithModeration Contract", function () {
    it("should prevent unregistered users from tweeting", async function () {
      await expect(
        twitter.connect(user1).createTweet("This is my first tweet!")
      ).to.be.revertedWith("User not registered");
    });

    it("should allow registered users to create tweets", async function () {
      await profile.connect(user1).setProfile("User1", "Hello, I'm User1!");
      await twitter.connect(user1).createTweet("This is my first tweet!");

      const tweets = await twitter.Tweets(user1.address);
      expect(tweets.length).to.equal(1);
      expect(tweets[0].content).to.equal("This is my first tweet!");
    });

    it("should allow users to flag a tweet", async function () {
      await profile.connect(user1).setProfile("User1", "Hello, I'm User1!");
      await twitter.connect(user1).createTweet("This is a test tweet.");

      await profile.connect(user2).setProfile("User2", "I'm User2.");
      await twitter.connect(user2).flagTweet(user1.address, 0);

      const flaggedTweet = await twitter.Tweets(user1.address, 0);
      expect(flaggedTweet.flags).to.equal(1);
    });

    it("should allow moderators to remove tweets", async function () {
      await twitter.connect(owner).addModerator(moderator.address);

      await profile.connect(user1).setProfile("User1", "Hello, I'm User1!");
      await twitter.connect(user1).createTweet("This is a test tweet.");

      await twitter
        .connect(moderator)
        .removeTweet(user1.address, 0, "Inappropriate content");

      const removedTweet = await twitter.Tweets(user1.address, 0);
      expect(removedTweet.removed).to.be.true;
    });

    it("should auto-remove flagged tweets when threshold is reached", async function () {
      await profile.connect(user1).setProfile("User1", "Hello, I'm User1!");
      await profile.connect(user2).setProfile("User2", "I'm User2.");
      const user3 = ethers.Wallet.createRandom(); // Simulate a third user

      await twitter.connect(user1).createTweet("This tweet will be flagged.");

      // Flag the tweet until it exceeds the threshold
      await twitter.connect(user2).flagTweet(user1.address, 0);
      await twitter.connect(owner).addModerator(user3.address); // Simulate moderation

      await expect(await twitter.Tweets(user1.address, 0)).to.equal(true);
    });
  });
});
