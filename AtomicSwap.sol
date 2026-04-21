// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AtomicSwap {
    struct Swap {
        address initiator;
        address participant;
        address token;
        uint256 amount;
        bytes32 hashLock;
        uint256 lockTime;
        bool claimed;
        bool refunded;
        bytes32 secret;
    }

    mapping(bytes32 => Swap) public swaps;

    event SwapInitiated(bytes32 indexed swapId, address initiator, address participant);
    event SwapClaimed(bytes32 indexed swapId, bytes32 secret);
    event SwapRefunded(bytes32 indexed swapId);

    function initiate(
        bytes32 _swapId,
        address _participant,
        address _token,
        uint256 _amount,
        bytes32 _hashLock,
        uint256 _lockTime
    ) external {
        require(swaps[_swapId].initiator == address(0), "Swap exists");
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);

        swaps[_swapId] = Swap({
            initiator: msg.sender,
            participant: _participant,
            token: _token,
            amount: _amount,
            hashLock: _hashLock,
            lockTime: block.timestamp + _lockTime,
            claimed: false,
            refunded: false,
            secret: 0x0
        });

        emit SwapInitiated(_swapId, msg.sender, _participant);
    }

    function claim(bytes32 _swapId, bytes32 _secret) external {
        Swap storage swap = swaps[_swapId];
        require(keccak256(abi.encodePacked(_secret)) == swap.hashLock, "Invalid secret");
        require(!swap.claimed && !swap.refunded, "Finished");

        swap.claimed = true;
        swap.secret = _secret;
        IERC20(swap.token).transfer(swap.participant, swap.amount);

        emit SwapClaimed(_swapId, _secret);
    }

    function refund(bytes32 _swapId) external {
        Swap storage swap = swaps[_swapId];
        require(block.timestamp >= swap.lockTime, "Not expired");
        require(!swap.claimed && !swap.refunded, "Finished");

        swap.refunded = true;
        IERC20(swap.token).transfer(swap.initiator, swap.amount);

        emit SwapRefunded(_swapId);
    }
}
