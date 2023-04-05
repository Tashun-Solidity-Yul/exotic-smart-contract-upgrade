// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library LibERC721 {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.lib.erc721.storage");

    struct ERC721UpgradableStorage {

        // owner of contract and who collects payments
        address _contractOwner;

        // Erc20 payment token address
        address _tokenAddress;

        // Token price in ERC20 amount
        uint256 _nftPrice;

        // Token name
        string _name;

        // Token symbol
        string _symbol;

        // incrementing token Id
        uint256 _tokenIdCounter;

        // Mapping from token ID to owner address
        mapping(uint256 => address) _owners;

        // Mapping owner address to token count
        mapping(address => uint256) _balances;

        // Mapping from token ID to approved address
        mapping(uint256 => address) _tokenApprovals;

        // Mapping from owner to operator approvals
        mapping(address => mapping(address => bool)) _operatorApprovals;

        // upgradable gap
        uint256[44] __gap;
    }

    function diamondStorage() internal pure returns (ERC721UpgradableStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

}
