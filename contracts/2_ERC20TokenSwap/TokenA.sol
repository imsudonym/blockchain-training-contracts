// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenA is ERC20 {

    address public owner;

    constructor() ERC20("Token A", "TKA") {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Access denied");
        _;
    }

    function mint(uint256 amount) public onlyOwner {
        _mint(msg.sender, amount);
    }
}
