// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Attack} from "../src/Attack.sol";
import {Good} from "../src/Good.sol";
import {console} from "forge-std/console.sol";

contract AttackTester is Test {
    Good public goodContract;
    Attack public attackContract;

    function setUp() public {
        vm.prank(vm.addr(420));
        goodContract = new Good();

        attackContract = new Attack(address(goodContract));
    }
    function test_attack() public {
        // Get two addresses using their private keys
        address address1 = vm.addr(1);
        address address2 = vm.addr(2);

        //add funds to the addresses
        deal(address1, 100 ether);
        deal(address2, 100 ether);

        //Initially let address1 become the current winner of the auction
        //impersonate address1 for sending a transaction to the Good Contract
        vm.prank(address1);
        goodContract.setCurrentAuctionPrice{value: 1 ether}();

        // Start the attack and make Attack.sol the current winner of the auction
        attackContract.attack{value: 3 ether}();

        // Now let's try making address2 the current winner of the auction
        vm.prank(address2);
        goodContract.setCurrentAuctionPrice{value: 4 ether}();

        // Balance of the Good Contract should be equal 0
        assertEq(goodContract.currentWinner(), address(attackContract));
    }
}
