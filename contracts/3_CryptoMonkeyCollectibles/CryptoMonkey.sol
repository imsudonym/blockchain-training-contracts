// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract CryptoMonkey {
	uint maxMonkeys = 100;
	
	struct Monkey {
		uint id;
		string name;
	}
	
    // token id  => Monkey
    mapping(uint256 => Monkey) idToMonkey;

    // token id => owner
    mapping(uint256 => address) monkeyToOwner;

	function _generateRandomId(string memory _str) private pure returns(uint) {
		uint rand = uint(keccak256(bytes(_str)));
		return rand % 3;
	}
	
	function createRandomMonkey(string memory _name) public {
		uint randId = _generateRandomId(_name);

        // idToMonkey[randId].id
        require(idToMonkey[randId].id == randId, "Zero or duplicate token id");

		createMonkey(randId, _name);
	}

    function createMonkey(uint _id, string memory _name) private {
        idToMonkey[_id] = Monkey(_id, _name);
	}
}