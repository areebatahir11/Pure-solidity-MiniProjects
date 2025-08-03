// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleLottery is Ownable {
    address[] public players;
    address public recentWinner;
    uint256 public entryFee;

    event LotteryEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    constructor(uint256 _entryFee) Ownable(msg.sender) {
        entryFee = _entryFee;
    }

    function enter() public payable {
        require(msg.value == entryFee, "Incorrect ETH sent!");
        players.push(msg.sender);
        emit LotteryEntered(msg.sender);
    }

    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function pickWinner() public onlyOwner {
        require(players.length > 0, "No players in the lottery");

        // ❗ Not secure randomness — okay for testing/demo
        uint256 randomIndex = uint256(
            keccak256(
                abi.encodePacked(block.difficulty, block.timestamp, players.length)
            )
        ) % players.length;

        address winner = players[randomIndex];
        recentWinner = winner;

        (bool sent, ) = payable(winner).call{value: address(this).balance}("");
        require(sent, "ETH Transfer failed");

        emit WinnerPicked(winner);

        // Reset the lottery
        delete players;
    }
}
