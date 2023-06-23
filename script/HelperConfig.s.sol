// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 keyHash;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
        address linkTokenContract;
    }

    NetworkConfig public s_networkConfig;

    constructor() {
        if (block.chainid == 31337) {
            s_networkConfig = getOrCreateAnvilConfig();
        } else if (block.chainid == 11155111) {
            s_networkConfig = getSepoliaConfig();
        } else {
            s_networkConfig = getSepoliaConfig();
        }
    }

    function getSepoliaConfig()
        public
        pure
        returns (NetworkConfig memory networkConfig)
    {
        networkConfig = NetworkConfig(
            0.01 ether,
            30,
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            768, // subscriptionId on Manager UI (https://vrf.chain.link/sepolia)
            500000,
            0x779877A7B0D9E8603169DdbD7836e478b4624789
        );
    }

    function getOrCreateAnvilConfig()
        public
        returns (NetworkConfig memory networkConfig)
    {
        if (s_networkConfig.vrfCoordinator != address(0)) {
            return s_networkConfig;
        }
        uint96 _fee = 0.1 ether;
        uint96 _link = 10 ** 18;
        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinator = new VRFCoordinatorV2Mock(
            _fee,
            _link
        );
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();
        networkConfig = NetworkConfig(
            0.01 ether,
            30,
            address(vrfCoordinator),
            0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            0,
            500000,
            address(linkToken)
        );
    }
}
