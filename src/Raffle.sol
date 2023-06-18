// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
 * @title Raffle
 * @author Gray Jiang
 * @notice A raffle contract for learning Solidity and foundry
 * @dev implement Chainlink vrf v2
 */
contract Raffle is VRFConsumerBaseV2 {
    error Raffle__InsufficientEntranceFee();
    error Raffle__InvalidTimestamp();
    error Raffle_transactionFailed();

    enum RaffleState {
        OPEN,
        CLOSED,
        CALCULATING
    }

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    uint256 private s_lastTimestamp;
    bytes32 private immutable i_keyHash;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    address payable[] private s_participants;
    RaffleState private s_raffleState;

    event EnterRaffle(address indexed _participant);
    event WinnerPicked(address indexed _winner);

    constructor(
        uint256 _entranceFee,
        uint256 _interval,
        uint256 _lastTimestamp,
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint64 _subscriptionId,
        uint32 _callbackGasLimit
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        i_entranceFee = _entranceFee;
        i_interval = _interval;
        s_lastTimestamp = _lastTimestamp;
        i_vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        i_keyHash = _keyHash;
        i_subscriptionId = _subscriptionId;
        i_callbackGasLimit = _callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable returns (bool) {
        if (msg.value < i_entranceFee) {
            revert Raffle__InsufficientEntranceFee();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__InvalidTimestamp();
        }
        s_participants.push(payable(msg.sender));
        emit EnterRaffle(msg.sender);
        return true;
    }

    function pickWinner() public returns (bool) {
        if (block.timestamp - s_lastTimestamp < i_interval) {
            revert Raffle__InvalidTimestamp();
        }
        s_raffleState = RaffleState.CALCULATING;
        i_vrfCoordinator.requestRandomWords(
            i_keyHash,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        return true;
    }

    function fulfillRandomWords(
        uint256,
        uint256[] memory randomWords
    ) internal override {
        uint256 winnerIndex = randomWords[0] % s_participants.length;
        address payable _winner = s_participants[winnerIndex];
        s_participants = new address payable[](0);
        s_lastTimestamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
        (bool success, ) = _winner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle_transactionFailed();
        }
        emit WinnerPicked(_winner);
    }

    /** Getter */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
}
