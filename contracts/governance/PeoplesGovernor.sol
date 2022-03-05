// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/compatibility/GovernorCompatibilityBravo.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";

/// Governor that takes 1 vote per palm holder
contract PeoplesGovernor is Governor, GovernorVotes, GovernorVotesQuorumFraction{
    struct ProposalVote {
        uint256 againstVotes;
        uint256 forVotes;
        uint256 abstainVotes;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => ProposalVote) private _proposalVotes;
    enum VoteType {
        Against,
        For,
        Abstain
    }

    constructor(IVotes _token)
        Governor("PeopleGovernor")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
    {}

    function votingDelay() public pure override returns (uint256) {
        return 6575; // 1 day
    }

    function votingPeriod() public pure override returns (uint256) {
        return 46027; // 1 week
    }

    function proposalThreshold() public pure override returns (uint256) {
        return 0;
    }

    function hasVoted(uint256 proposalId, address account) public view virtual override returns (bool) {
        return _proposalVotes[proposalId].hasVoted[account];
    }

    function COUNTING_MODE() public pure virtual override returns (string memory) {
        return "support=bravo&wuorum=for,abstain";
    }

    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 weight
    ) internal override {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];

        require(!proposalVote.hasVoted[account], "PeoplesGovernor: vote already cast");
        proposalVote.hasVoted[account] = true;

        if (support == uint8(VoteType.Against)) {
            proposalVote.againstVotes++;
        }
        else if (support == uint8(VoteType.For)) {
            proposalVote.forVotes++;
        }
        else if (support == uint8(VoteType.Abstain)) {
            proposalVote.abstainVotes++;
        }
        else {
            revert("PeoplesGovernor: invalid value for enum VoteType");
        }
    }

    function _quorumReached(uint256 proposalId) internal view virtual override returns (bool) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];

        return quorum(proposalSnapshot(proposalId)) <= proposalVote.forVotes + proposalVote.abstainVotes;
    }

    function _voteSucceeded(uint256 proposalId) internal view virtual override returns (bool) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];

        return proposalVote.forVotes > proposalVote.againstVotes;
    }
}