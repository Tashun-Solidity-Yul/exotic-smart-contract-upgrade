//// SPDX-License-Identifier: UNLICENSED
//pragma solidity ^0.8.0;
//
//import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
//import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
//import "./storage/AppStorageFacetShare.sol";
//import "./Facets/ERC20UpgradeableFacet.sol";
//import "./Facets/OwnableFacet.sol";
//
//contract ERC20Facet is InitializerFacet, UUPSUpgradeable, OwnableFacet,ERC20UpgradeableFacet {
//    /// @custom:oz-upgrades-unsafe-allow constructor
//    constructor() {
//        _disableInitializers();
//    }
//
//    function initialize() initializer public {
//        __ERC20_init("ERC20Facet", "MTK");
//        __Ownable_init();
//        __UUPSUpgradeable_init();
//    }
//
//    function mint(address to, uint256 amount) public onlyOwner {
//        _mint(to, amount);
//    }
//
//    function _authorizeUpgrade(address newImplementation)
//    internal
//    onlyOwner
//    override
//    {}
//}