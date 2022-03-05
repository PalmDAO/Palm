// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/compatibility/GovernorCompatibilityBravo.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";

/// Governor that takes 1 vote per palm holder
contract PeoplesGovernor is Governor, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction{
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

    function getVotes(address account, uint256 blockNumber) public view override(IGovernor, GovernorVotes) returns (uint256) {
        if (super.getVotes(account, blockNumber) > 0) {
            return 1;
        }
        return 0;
    }

}