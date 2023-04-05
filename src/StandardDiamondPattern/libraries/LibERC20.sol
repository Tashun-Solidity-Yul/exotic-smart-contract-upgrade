// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library LibERC20 {
    bytes32 constant DIAMOND_STORAGE_POSITION  = keccak256("diamond.standard.lib.erc20.storage");

    struct ERC20UpgradableStorage {

        // owners to balances mapping
        mapping(address => uint256) _balances;

        // owner address to beneficiary to allowance approved mapping
        mapping(address => mapping(address => uint256)) _allowances;

        // total minted supply
        uint256 _totalSupply;

        string _name;
        string _symbol;

        // upgradable gap
        uint256[45] __gap;
    }

    function diamondStorage() internal pure returns (ERC20UpgradableStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

}
