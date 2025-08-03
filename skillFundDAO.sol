// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SkillFundDAO is ReentrancyGuard, Ownable {
    enum GoalStatus { Proposed, Approved, Rejected, Completed, Expired }

    struct LearningGoal {
        uint id;
        string title;
        string description;
        address creator;
        GoalStatus status;
        uint amountFunded;
        address[] voters;
        uint votesFor;
        uint votesAgainst;
        uint deadline;
        mapping(address => uint) funders;
        mapping(address => bool) doubleVoting;
    }

    mapping(uint => LearningGoal) private goals;
    mapping(address => uint[]) public userGoals;
    uint public goalCount;

    event GoalCreated(uint goalId, address creator);
    event GoalFunded(uint goalId, address funder, uint amount);
    event Voted(uint goalId, address voter, bool approved);
    event GoalCompleted(uint goalId);
    event FundsWithdrawn(uint goalId, address to, uint amount);

    // --- Create Goal ---
    function createGoal(string memory _title, string memory _description, uint durationInDays) public {
        LearningGoal storage goal = goals[goalCount];
        goal.id = goalCount;
        goal.title = _title;
        goal.description = _description;
        goal.creator = msg.sender;
        goal.deadline = block.timestamp + durationInDays * 1 days;
        goal.status = GoalStatus.Proposed;

        userGoals[msg.sender].push(goalCount);
        emit GoalCreated(goalCount, msg.sender);
        goalCount++;
    }

    // --- Fund Goal ---
    function fundGoal(uint goalId) public payable {
        require(msg.value > 0, "No funds sent");
        LearningGoal storage goal = goals[goalId];

        goal.funders[msg.sender] += msg.value;
        goal.amountFunded += msg.value;

        emit GoalFunded(goalId, msg.sender, msg.value);
    }

    // --- Vote ---
    function voteOnGoal(uint goalId, bool approve) public {
        LearningGoal storage goal = goals[goalId];
        require(!goal.doubleVoting[msg.sender], "Already voted");
        require(block.timestamp <= goal.deadline, "Voting closed");

        if (approve) {
            goal.votesFor++;
        } else {
            goal.votesAgainst++;
        }

        goal.voters.push(msg.sender);
        goal.doubleVoting[msg.sender] = true;

        emit Voted(goalId, msg.sender, approve);
    }

    // --- Mark Goal As Completed ---
    function markAsCompleted(uint goalId) public {
        LearningGoal storage goal = goals[goalId];
        require(msg.sender == goal.creator, "Not goal creator");
        require(goal.votesFor > goal.votesAgainst, "Not enough support");

        goal.status = GoalStatus.Completed;
        emit GoalCompleted(goalId);
    }

    // --- Withdraw Funds ---
    function withdrawFunds(uint goalId) public nonReentrant {
        LearningGoal storage goal = goals[goalId];
        require(msg.sender == goal.creator, "Not goal creator");
        require(goal.status == GoalStatus.Completed, "Goal not completed");
        uint amount = goal.amountFunded;
        goal.amountFunded = 0;

        payable(msg.sender).transfer(amount);
        emit FundsWithdrawn(goalId, msg.sender, amount);
    }

    // --- View Goal Info ---
    function getGoal(uint id) public view returns (
        string memory title,
        string memory description,
        address creator,
        uint amount,
        GoalStatus status,
        uint deadline,
        uint votesFor,
        uint votesAgainst
    ) {
        LearningGoal storage g = goals[id];
        return (g.title, g.description, g.creator, g.amountFunded, g.status, g.deadline, g.votesFor, g.votesAgainst);
    }

    receive() external payable {}
}
