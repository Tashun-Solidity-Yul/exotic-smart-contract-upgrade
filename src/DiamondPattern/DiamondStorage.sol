// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Diamond storage is a contract storage strategy that is used in proxy contracts and diamonds.

// It greatly simplifies organizing and using state variables in proxy contracts and diamonds.

// Diamond storage relies on Solidity structs that contain sets of state variables.

// A struct can be defined with state variables and then used in a particular position in contract
// storage. The position can be determined by a hash of a unique string or other data. The string
// acts like a namespace for the struct. For example a diamond storage string for a struct could
// be 'com.mycompany.projectx.mystruct'. That will look familiar to you if you have used programming
// languages  that use namespaces.

// Namespaces are used in some programming languages to package data and code together as separate
// reusable units. Diamond storage packages sets of state variables as separate, reusable data units
// in contract storage.

// Let's look at a simple example of diamond storage:

library LibDiamondOne {
    bytes32 constant LIB_DIAMOND_ONE = keccak256("com.tsc.diamond.one");

    struct DiamondOneStorage {
        // tokenId => owner
        mapping (uint256 => address) tokenIdToOwner;
        // owner => count of tokens owned
        mapping (address => uint256) ownerToNFTokenCount;

        string name;
        string symbol;
    }

    // Return ERC721 storage struct for reading and writing
    function getStorage() internal pure returns (DiamondOneStorage storage storageStruct) {
        bytes32 position = LIB_DIAMOND_ONE;
        assembly {
            storageStruct.slot := position
        }
    }
}


