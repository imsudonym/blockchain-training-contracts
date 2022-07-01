// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract CatsNft is ERC721 {
	uint public maxSupply = 5;
	uint public totalSupply;
	mapping(address => uint256[]) public ownerTokens;

	event Minted(uint256 tokenId, address minter);

	constructor() ERC721("CatsNft", "CATS") {}
	
	function mint() public {
		require(totalSupply <= maxSupply, "max total supply reached");
		
		uint256 tokenId = ++totalSupply;
		_safeMint(msg.sender, tokenId);

		ownerTokens[msg.sender].push(tokenId);
		emit Minted(tokenId, msg.sender);
	}

	function ownerTokensLength(address _owner) external view returns(uint) {
		return ownerTokens[_owner].length;
	}

	function _baseURI() internal pure override returns (string memory) {
        return "https://gateway.pinata.cloud/ipfs/QmbFwhaH1wcHuXyAwerAmJg98KbeWSPxSxzFvH9cWHpGQy/";
    }
}