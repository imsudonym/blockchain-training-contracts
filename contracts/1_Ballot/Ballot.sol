// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Ballot {

    struct Voter {
        bool voted;
        uint vote;
    }

    struct Candidate {
        string name;
        uint voteCount;
    }

    mapping(address => Voter) public voters;
    Candidate[] public candidates;
    bool public votingEnabled = false;
    address public chairperson;
    

    modifier isVotingEnabled {
        require(votingEnabled, "Voting not enabled");
        _;
    }

    modifier onlyChairperson {
        require(msg.sender == chairperson, "Must be chairperson");
        _;
    }

    constructor(string[] memory candidateNames) {
        chairperson = msg.sender;
        for (uint i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate(candidateNames[i],0));
        }
    }

    function getCandidatesLength() public view returns(uint) {
        return candidates.length;
    }

    function setVotingState(bool _votingEnabled) public onlyChairperson {
        votingEnabled = _votingEnabled;
    }

    function vote(uint candidate) public isVotingEnabled {
        require(!voters[msg.sender].voted, "Already voted.");

        voters[msg.sender].voted = true;
        voters[msg.sender].vote = candidate;

        candidates[candidate].voteCount++;
    }

    function getWinningCandidate() private view returns (uint)  {
        uint winningVoteCount = 0;
        uint winningCandidate_ = 0;
        for (uint index = 0; index < candidates.length; index++) {

            if (candidates[index].voteCount > winningVoteCount) {
                winningVoteCount = candidates[index].voteCount;
                winningCandidate_ = index;
            } 
        }

        return winningCandidate_;
    }

    function getWinner() public view returns (string memory winnerName){
        uint winner = getWinningCandidate();
        if (candidates[winner].voteCount > 0) {
            winnerName = candidates[winner].name;
        }
    }
}