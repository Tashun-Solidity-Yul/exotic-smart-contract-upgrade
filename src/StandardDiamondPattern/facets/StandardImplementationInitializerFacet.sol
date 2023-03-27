// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./UtilFacet.sol";
import "../libraries/LibInitializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

contract StandardImplementationInitializerFacet is StandardImplementationUtilFacet {
    using AddressUpgradeable for address;
    bytes32 immutable DIAMOND_STORAGE_POSITION;

    constructor(string memory package) {
        DIAMOND_STORAGE_POSITION = keccak256(abi.encode(package));
    }
    /**
      * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contractst.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        LibInitializable.StandardImplementationInitializable storage st = LibInitializable.diamondStorage(DIAMOND_STORAGE_POSITION);
        bool isTopLevelCall = !st._initializing;
        require(
            (isTopLevelCall && st._initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && st._initialized == 1),
            "Initializable: contract is already initialized"
        );
        st._initialized = 1;
        if (isTopLevelCall) {
            st._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            st._initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contractst.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        LibInitializable.StandardImplementationInitializable storage st = LibInitializable.diamondStorage(DIAMOND_STORAGE_POSITION);
        require(!st._initializing && st._initialized < version, "Initializable: contract is already initialized");
        st._initialized = version;
        st._initializing = true;
        _;
        st._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        LibInitializable.StandardImplementationInitializable storage st = LibInitializable.diamondStorage(DIAMOND_STORAGE_POSITION);
        require(st._initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxiest.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        LibInitializable.StandardImplementationInitializable storage st = LibInitializable.diamondStorage(DIAMOND_STORAGE_POSITION);
        require(!st._initializing, "Initializable: contract is initializing");
        if (st._initialized < type(uint8).max) {
            st._initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        LibInitializable.StandardImplementationInitializable storage st = LibInitializable.diamondStorage(DIAMOND_STORAGE_POSITION);
        return st._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        LibInitializable.StandardImplementationInitializable storage st = LibInitializable.diamondStorage(DIAMOND_STORAGE_POSITION);
        return st._initializing;
    }


}
