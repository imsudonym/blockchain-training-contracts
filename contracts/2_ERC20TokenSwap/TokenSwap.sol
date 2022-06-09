// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract TokenSwap {
    IERC20 public tokenA;
    IERC20 public tokenB;

    enum SwapType {AforB, BforA}

    struct Swap {
        bytes32 id;
        SwapType swapType;
        address creator;
        address swappedBy;
        uint256 amountFrom;
        uint256 amountTo;
        bool isSwapped;
    }

    mapping(address => bytes32[]) public ownerToSwaps;
    mapping(bytes32 => Swap) public swapInfo;
    uint256 public globalSwapCount;

    constructor(
        address _tokenA,
        address _tokenB
    ) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function createSwap(SwapType swapType, uint256 amountFrom, uint256 amountTo) public {
        IERC20 token;
        if (swapType == SwapType.AforB) {
            require(
                tokenA.allowance(msg.sender, address(this)) >= amountFrom,
                "Token A allowance too low"
            );
            token = tokenA;
        } else if (swapType == SwapType.BforA) {
            require(
                tokenB.allowance(msg.sender, address(this)) >= amountFrom,
                "Token B allowance too low"
            );
            token = tokenB;
        }

        bytes32 swapHash = _hash(globalSwapCount, msg.sender);
        swapInfo[swapHash] = Swap(swapHash, swapType, msg.sender, address(0), amountFrom, amountTo, false);
        ownerToSwaps[msg.sender].push(swapHash);

        globalSwapCount++;

        _safeTransferFrom(token, msg.sender, address(this), amountFrom);
    }

    function _hash(uint256 _index, address _creator) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(block.number, _index, _creator));
    }

    function swap(bytes32 id) public {
        Swap memory tempSwap = swapInfo[id];
        require(tempSwap.creator != msg.sender, "caller is swap creator");
        require(tempSwap.creator != address(0), "creator zero address");

        IERC20 tokenFrom;
        IERC20 tokenTo;
        if (tempSwap.swapType == SwapType.AforB) {
            require(
                tokenB.allowance(msg.sender, address(this)) >= tempSwap.amountTo,
                "Token B allowance too low"
            );
            tokenFrom = tokenA;
            tokenTo = tokenB;
        } else if (tempSwap.swapType == SwapType.BforA) {
            require(
                tokenA.allowance(msg.sender, address(this)) >= tempSwap.amountTo,
                "Token A allowance too low"
            );
            tokenFrom = tokenB;
            tokenTo = tokenA;
        }

        tokenFrom.transfer(msg.sender, tempSwap.amountFrom);
        _safeTransferFrom(tokenTo, msg.sender, tempSwap.creator, tempSwap.amountTo);
        
    }

    function _safeTransferFrom(
        IERC20 token,
        address sender,
        address recipient,
        uint amount
    ) private {
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }
}