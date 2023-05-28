// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract AppStorageFacetShare {
    struct FacetStorage {
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        uint256 _totalSupply;
        string _name;
        string _symbol;
        address _owner;
        uint8 _initialized;
        bool _initializing;
        address __self;

    mapping(uint256 => address) _owners;
    mapping(uint256 => address) _tokenApprovals;
    mapping(address => mapping(address => bool)) _operatorApprovals;

    }
}
