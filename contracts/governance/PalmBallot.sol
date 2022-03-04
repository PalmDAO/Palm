// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract PalmBallot {
    struct Voter {
        bool canVote;
        uint256 weight;
        mapping(uint256 => bool) didVote; // Proposal ID to has voted
        mapping(uint256 => bool) voteValue; // Proposal ID to vote value
    }

    struct Proposal {
        // If you can limit the length to a certain number of bytes,
        // always use one of bytes1 to bytes32 because they are much cheaper
        bytes32 name; // short name (up to 32 bytes)
        string description; // Description of proposal
        bool isOpen; // open for voting
        uint256 peopleVoteCount; // number of accumulated votes
        uint256 peopleApproveVotes; // number of approve votes
        uint256 whaleVoteCount; // number of accumulated votes
        uint256 whaleApproveVotes; // number of approve votes
    }

    address public chairperson;

    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    constructor() {
        chairperson = msg.sender;
    }

    function getProposals() public view returns (Proposal[] memory) {
        return proposals;
    }

    function giveRightToVote(address voter) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(!voters[voter].canVote, "The voter can already vote.");
        require(voters[voter].weight == 0);
        // require(voter.palm >= 1000, "Not enough PALM to vote")
        voters[voter].canVote = true;
        voters[voter].weight = 1; // This need to be the amount of PALM they have.
    }

    function createProposal(bytes32 name, string memory description) public {
        proposals.push(
            Proposal({
                name: name,
                description: description,
                isOpen: true,
                peopleVoteCount: 0,
                peopleApproveVotes: 0,
                whaleVoteCount: 0,
                whaleApproveVotes: 0
            })
        );
    }

    /**
     * Called to approve or deny a proposal
     */
    function vote(uint256 proposal, bool approve) public {
        require(proposals[proposal].isOpen, "Voting has ended.");
        Voter storage sender = voters[msg.sender];
        require(sender.canVote, "Has no right to vote (not enough PALM?)");
        require(!sender.didVote[proposal], "Already voted.");
        sender.didVote[proposal] = true;
        sender.voteValue[proposal] = approve;

        if (approve) {
            proposals[proposal].peopleApproveVotes++;
            proposals[proposal].whaleApproveVotes += sender.weight;
        }

        // If 'proposal' is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].peopleVoteCount++;
        proposals[proposal].whaleVoteCount += sender.weight;
    }

    /**
     * Used to close voting for a proposal
     */
    function closeVoting(uint256 proposal) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can close voting."
        );
        require(proposals[proposal].isOpen, "Voting already closed.");
        proposals[proposal].isOpen = false;
    }

    /**
     * @dev Computes the proposal result by taking all previous votes into account.
     * @return proposalResult_ whether the proposal passed or not
     */
    function proposalResult(uint256 proposal)
        public
        view
        returns (bool proposalResult_)
    {
        Proposal storage currentProposal = proposals[proposal];
        require(!currentProposal.isOpen, "Voting still open.");
        // require(currentProposal.timePassed >= 5days, "Voting still in progress")
        uint256 peopleResults = (currentProposal.peopleApproveVotes * 100) /
            currentProposal.peopleVoteCount;
        uint256 whaleResults = (currentProposal.whaleApproveVotes * 100) /
            currentProposal.whaleVoteCount;
        if (peopleResults >= 75 && whaleResults >= 75) {
            return true;
        } else {
            return false;
        }
    }
}
