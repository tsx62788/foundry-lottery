// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

// import {StdCheats} from "forge-std/StdCheats.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;
    address public s_player = makeAddr("player");
    uint256 public constant ENTRANCE_FEE = 0.01 ether;
    uint256 public constant START_BALANCE = 100 ether;

    event EnterRaffle(address indexed _participant);

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();
        // (
        //     uint256 entranceFee,
        //     uint256 interval,
        //     address vrfCoordinator,
        //     bytes32 keyHash,
        //     uint64 subscriptionId,
        //     uint32 callbackGasLimit
        // ) = helperConfig.s_networkConfig();
        vm.deal(s_player, START_BALANCE);
    }

    function testRaffleIsOpening() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleRevertsWhenYouDontPayEnough() public {
        vm.prank(s_player);
        vm.expectRevert(Raffle.Raffle__InsufficientEntranceFee.selector);
        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public {
        vm.prank(s_player);
        raffle.enterRaffle{value: ENTRANCE_FEE}();
        address _playerRecorded = raffle.getPlayer(0);
        assert(_playerRecorded == s_player);
    }

    function testEmitsEventsOnEtnerRaffle() public {
        vm.prank(s_player);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnterRaffle(s_player);
        raffle.enterRaffle{value: ENTRANCE_FEE}();
    }
}
