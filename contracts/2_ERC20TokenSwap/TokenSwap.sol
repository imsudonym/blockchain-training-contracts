// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract TokenSwap {
    
    enum SwapType {AforB, BforA}

    struct Swap {
        SwapType swapType;
        address creator;
        address swappedBy;
        uint256 amountFrom;
        uint256 amountTo;
        bool isSwapped;
    }

    Swap[] public swaps;
    mapping(address => uint256[]) public ownerToSwaps;

    IERC20 public tokenA;
    IERC20 public tokenB;

    constructor(
        address _tokenA,
        address _tokenB
    ) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function getSwapsLength() public view returns (uint256) {
        return swaps.length;
    }

    function getOwnerSwapsLength(address owner) public view returns (uint256) {
        return ownerToSwaps[owner].length;
    }

    function createSwap(SwapType swapType, uint256 amountFrom, 
        uint256 amountTo) public {

        uint256 swapId = swaps.length;
        ownerToSwaps[msg.sender].push(swapId);
        swaps.push(Swap(swapType, msg.sender, 
            address(0), amountFrom, amountTo, false));

        if (swapType == SwapType.AforB) {
            tokenA.transferFrom(msg.sender, address(this), amountFrom);
        } else if (swapType == SwapType.BforA) {
            tokenB.transferFrom(msg.sender, address(this), amountFrom);
        }
    }

    function swap(uint256 id) public {
        Swap storage swapInfo = swaps[id];
        require(swapInfo.isSwapped == false, "Swap is already fulfilled");

        swapInfo.isSwapped = true;
        swapInfo.swappedBy = msg.sender;

        IERC20 tokenFrom;
        IERC20 tokenTo;

        if (swapInfo.swapType == SwapType.AforB) {
            tokenFrom = tokenA;
            tokenTo = tokenB;
        } else if (swapInfo.swapType == SwapType.BforA) {
            tokenFrom = tokenB;
            tokenTo = tokenA;
        }

        tokenFrom.transfer(msg.sender, swapInfo.amountFrom);
        tokenTo.transferFrom(msg.sender, swapInfo.creator, swapInfo.amountTo);
    }
}