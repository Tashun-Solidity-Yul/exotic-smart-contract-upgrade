// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./LibDiamondStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract FacetAppStorage {

    struct AppStorage {
        // ERC20 balances and ERC721 balances
        mapping(address => uint256) _balancesERC20;
        mapping(address => uint256) _balancesERC721;
        // ERC20 allowances
        mapping(address => mapping(address => uint256)) _allowances;
        // ERC20 _totalSupply
        uint256 _totalSupply;

        // ERC20 and ERC721 _name _symbol
        string _nameERC20;
        string _nameERC721;
        string _symbolERC20;
        string _symbolERC721;

        // ERC721 _owners _tokenApprovals _operatorApprovals
        mapping(uint256 => address) _owners;
        mapping(uint256 => address) _tokenApprovals;
        mapping(address => mapping(address => bool)) _operatorApprovals;

        uint256 _tokenIdCounter;

    }

}

library LibAppStorage {
    function diamondStorage() internal pure returns (FacetAppStorage.AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}

contract Modifiers {
    FacetAppStorage.AppStorage internal s;

    modifier onlyOwner() {
        require(msg.sender == LibDiamondStorage.contractOwner(), "LibAppStorage: No access");
        _;
    }

}
