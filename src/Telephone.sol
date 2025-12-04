// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
        emit LogAddresses(tx.origin, msg.sender);
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }

    event LogAddresses(address indexed txOrigin, address indexed msgSender);
}