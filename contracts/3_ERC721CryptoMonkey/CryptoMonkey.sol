// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract CryptoMonkey is ERC721 {
	uint256 maxMonkeys = 100;
	uint256 totalSupply;

	mapping(address => uint256[]) public ownerTokens;

	constructor() ERC721("CryptoMonkey", "CM") {}
	
	function mintMonkey() public {
		require(totalSupply <= maxMonkeys, "max total supply reached");
		
		uint256 tokenId = ++totalSupply;
		_safeMint(msg.sender, tokenId);

		ownerTokens[msg.sender].push(tokenId);
	}

	function ownerTokensLength(address owner) public view returns(uint256) {
		return ownerTokens[owner].length;
	}
}