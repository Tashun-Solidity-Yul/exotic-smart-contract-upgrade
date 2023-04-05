// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library LibInitializable {


    struct StandardImplementationInitializable {

        // metadata - versioning purposes and to track whether it is initialized
        uint8 _initialized;
        // metadata - while initializing true
        bool _initializing;
    }

    function diamondStorage(bytes32 position) internal pure returns (StandardImplementationInitializable storage ds) {
        assembly {
            ds.slot := position
        }
    }
}