// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

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

contract FundSubscription is Script {
    uint96 constant FUND_AMOUNT = 30 ether;

    function FundSubscriptionUsingHelperConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinator,
            ,
            uint64 subscriptionId,
            ,
            address linkTokenContract
        ) = helperConfig.s_networkConfig();
        fundSubscription(vrfCoordinator, subscriptionId, linkTokenContract);
    }

    function fundSubscription(
        address vrfCoordinator,
        uint64 subscriptionId,
        address linkTokenContract
    ) public {
        console.log(
            "AMOUNT %s",
            FUND_AMOUNT,
            "LINK TOKEN %s",
            linkTokenContract
        );
        console.log("Funding subscription id on chain %s", block.chainid);
        if (block.chainid == 31337) {
            vm.startBroadcast();
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(
                subscriptionId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(linkTokenContract).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
            vm.stopBroadcast();
        }
    }

    function run() external {
        FundSubscriptionUsingHelperConfig();
    }
}

contract AddConsumer is Script {
    function AddConsumerUsingHelperConfig(address raffle) public {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCoordinator, , uint64 subscriptionId, , ) = helperConfig
            .s_networkConfig();
        addConsumer(vrfCoordinator, subscriptionId, raffle);
    }

    function addConsumer(
        address vrfCoordinator,
        uint64 subscriptionId,
        address consumer
    ) public {
        vm.startBroadcast();
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(
            subscriptionId,
            consumer
        );
        vm.stopBroadcast();
    }

    function run() external {
        address raffle = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        AddConsumerUsingHelperConfig(raffle);
    }
}
