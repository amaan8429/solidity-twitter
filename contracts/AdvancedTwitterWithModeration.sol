// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

pragma solidity ^0.8.26;

interface IProfile {
    struct UserProfile {
        string displayName;
        string bio;
    }

    function getProfile(address _user) external view returns (UserProfile memory);
}

contract AdvancedTwitterWithModeration is Ownable(address(this)) {
    using Counters for Counters.Counter;

    uint256 public MAX_TWEET_LENGTH = 280;
    uint256 public FLAG_THRESHOLD = 3;

    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
        uint256 flags;
        bool removed;
    }

    IProfile profileContract;

    mapping(address => Tweet[]) public Tweets;
    mapping(uint256 => bool) public flaggedTweets; // Track flagged tweets by ID
    mapping(address => bool) public moderators; // Track platform moderators
    mapping(address => uint256) public strikeCount; // Track strikes against users

    event TweetCreated(uint256 id, address author, string content, uint256 timestamp);
    event TweetRemoved(uint256 id, address author, string reason);
    event TweetFlagged(uint256 id, address flaggedBy, address author, uint256 totalFlags);

    modifier onlyRegistered() {
        IProfile.UserProfile memory userProfileTemp = profileContract.getProfile(msg.sender);
        require(bytes(userProfileTemp.displayName).length > 0, "User not registered");
        _;
    }

    modifier onlyModerator() {
        require(moderators[msg.sender], "Only moderators can perform this action");
        _;
    }

    constructor(address _profileContract) {
        profileContract = IProfile(_profileContract);
    }

    // Add or Remove Moderators
    function addModerator(address _moderator) public onlyOwner {
        moderators[_moderator] = true;
    }

    function removeModerator(address _moderator) public onlyOwner {
        moderators[_moderator] = false;
    }

    // Create Tweet with Basic Profanity Filter
    function createTweet(string memory _tweet) public onlyRegistered {
        require(bytes(_tweet).length <= MAX_TWEET_LENGTH, "Tweet is too long");
        require(!_containsProfanity(_tweet), "Tweet contains inappropriate content");

        Tweet memory newTweet = Tweet({
            id: Tweets[msg.sender].length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0,
            flags: 0,
            removed: false
        });

        Tweets[msg.sender].push(newTweet);

        emit TweetCreated(newTweet.id, msg.sender, newTweet.content, newTweet.timestamp);
    }

    // Flag a Tweet
    function flagTweet(address _author, uint256 _tweetId) public onlyRegistered {
        require(_tweetId < Tweets[_author].length, "Tweet does not exist");
        require(!Tweets[_author][_tweetId].removed, "Tweet already removed");

        Tweets[_author][_tweetId].flags++;
        emit TweetFlagged(_tweetId, msg.sender, _author, Tweets[_author][_tweetId].flags);

        // Auto-remove if flag count exceeds threshold
        if (Tweets[_author][_tweetId].flags >= FLAG_THRESHOLD) {
            removeTweet(_author, _tweetId, "Flagged by community");
        }
    }

    // Remove a Tweet (Moderator Only)
    function removeTweet(
        address _author,
        uint256 _tweetId,
        string memory _reason
    ) public onlyModerator {
        require(_tweetId < Tweets[_author].length, "Tweet does not exist");
        require(!Tweets[_author][_tweetId].removed, "Tweet already removed");

        Tweets[_author][_tweetId].removed = true;
        strikeCount[_author]++; // Penalize the user

        emit TweetRemoved(_tweetId, _author, _reason);
    }

    // Basic Profanity Filter
    function _containsProfanity(string memory _content) internal pure returns (bool) {
        // Add your profanity words here
        string[3] memory bannedWords = ["badword1", "badword2", "badword3"];
        for (uint256 i = 0; i < bannedWords.length; i++) {
            if (_contains(_content, bannedWords[i])) {
                return true;
            }
        }
        return false;
    }

    function _contains(string memory _base, string memory _value) internal pure returns (bool) {
        return bytes(_base).length >= bytes(_value).length && keccak256(bytes(_base)) == keccak256(bytes(_value));
    }

    // Get a User's Strike Count
    function getStrikeCount(address _user) public view returns (uint256) {
        return strikeCount[_user];
    }

    // Adjust Flag Threshold
    function setFlagThreshold(uint256 _threshold) public onlyOwner {
        FLAG_THRESHOLD = _threshold;
    }
}
