// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract QuoteGenerator {
    enum Category {
        Islamic,
        Motivational,
        SelfLove,
        Gratitude
    }

    struct Quote {
        string text;
        address author;
        uint256 timestamp;
        Category _category;
        uint likes;
    }

    Quote[] public quotes;

    string[] private bannedWords;
    
   mapping(uint => mapping(address => bool)) public hasLiked;

    event QuoteSubmitted(
        string text,
        address indexed author,
        Category category,
        uint timestamp
    );
    
   event QuoteLiked(uint indexed quoteId, address indexed liker);

    modifier noAbuse(string memory _text) {
        for (uint i = 0; i < bannedWords.length; i++) {
            if (contains(_text, bannedWords[i])) {
                revert("Quote contains banned words!");
            }
        }
        _;
    }

    constructor() {
        //  Add banned words
        bannedWords = ["abuse", "hate", "stupid", "idiot"];

        // Add default quotes
        quotes.push(Quote("Allah is with the person who has patience.", msg.sender, block.timestamp, Category.Islamic,0));
        quotes.push(Quote("Keep Going, You're doing great!", msg.sender, block.timestamp, Category.Motivational,0));
        quotes.push(Quote("Love and respect yourself", msg.sender, block.timestamp, Category.SelfLove,0));
        quotes.push(Quote("Gratitude is the best attitude.", msg.sender, block.timestamp, Category.Gratitude,0));
        quotes.push(Quote("You are enough just the way you are!", msg.sender, block.timestamp, Category.SelfLove,0));
        quotes.push(Quote("Have faith in Allah, He has better plans for you.", msg.sender, block.timestamp, Category.Islamic,0));
        quotes.push(Quote("Success is on the way!", msg.sender, block.timestamp, Category.Motivational,0));
        quotes.push(Quote("Be different, Be bright, Be you!", msg.sender, block.timestamp, Category.SelfLove,0));
        quotes.push(Quote("Gratitude turns what we have into enough.", msg.sender, block.timestamp, Category.Gratitude,0));
        quotes.push(Quote("Thanks Allah for every little blessing in your life.", msg.sender, block.timestamp, Category.Gratitude,0));
        quotes.push(Quote("If you remember Allah, it means that Allah remembered you first.", msg.sender, block.timestamp, Category.Islamic,0));
        quotes.push(Quote("Hard work always pays off!", msg.sender, block.timestamp, Category.Motivational,0));
        quotes.push(Quote("Your happiness matters!", msg.sender, block.timestamp, Category.SelfLove,0));
        quotes.push(Quote("When you focus on the good, the good gets better.", msg.sender, block.timestamp, Category.Gratitude,0));
    }

    // Add new quote (with abuse check)
    function AddQuote(string memory _text, Category _c) public noAbuse(_text) {
        quotes.push(Quote(_text, msg.sender, block.timestamp, _c, 0));
        emit QuoteSubmitted(_text, msg.sender, _c, block.timestamp);
    }

    // Return random quote from specific category
    function getRandomQuoteByCategory(Category _c) public view returns (Quote memory) {
        uint256 count = 0;

        // Count quotes matching the category
        for (uint256 i = 0; i < quotes.length; i++) {
            if (quotes[i]._category == _c) {
                count++;
            }
        }

        require(count > 0, "No quotes found for this category");

        // Store matching quotes in memory
        Quote[] memory filtered = new Quote[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < quotes.length; i++) {
            if (quotes[i]._category == _c) {
                filtered[index++] = quotes[i];
            }
        }

        // Get pseudo-random index
        uint256 randomIndex = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.prevrandao, msg.sender)
            )
        ) % filtered.length;

        return filtered[randomIndex];
    }

    // String comparison helper
    function contains(string memory _text, string memory _word) internal pure returns (bool) {
        bytes memory textBytes = bytes(_text);
        bytes memory wordBytes = bytes(_word);

        if (wordBytes.length > textBytes.length) return false;

        for (uint i = 0; i <= textBytes.length - wordBytes.length; i++) {
            bool matching = true;
            for (uint j = 0; j < wordBytes.length; j++) {
                if (textBytes[i + j] != wordBytes[j]) {
                    matching = false;
                    break;
                }
            }
            if (matching) return true;
        }
        return false;
    }
     function likeQuote(uint _quoteId) public {
    require(_quoteId < quotes.length, "Invalid quote ID");
    require(!hasLiked[_quoteId][msg.sender], "You already liked this quote");

    quotes[_quoteId].likes++;
    hasLiked[_quoteId][msg.sender] = true;

    emit QuoteLiked(_quoteId, msg.sender);
}
}
