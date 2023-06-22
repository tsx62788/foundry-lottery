// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingHelperConfig()
        public
        returns (uint64 subId)
    {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCoordinator, , , , ) = helperConfig.s_networkConfig();
        subId = createSubscription(vrfCoordinator);
    }

    function createSubscription(
        address vfrCoordinator
    ) public returns (uint64 subId) {
        console.log("Creating subscription id on chain %s", block.chainid);
        vm.startBroadcast();
        subId = VRFCoordinatorV2Mock(vfrCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Your sub id is %s", subId);
        console.log("Please update sub id in script/HelperConfig.s.sol");
    }

    function run() external returns (uint64 subId) {
        subId = createSubscriptionUsingHelperConfig();
    }
}
