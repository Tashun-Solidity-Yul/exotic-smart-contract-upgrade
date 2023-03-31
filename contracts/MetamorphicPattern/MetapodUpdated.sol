pragma solidity 0.5.6;
import "hardhat/console.sol";

/**
 * @title Metapod
 * @author 0age
 * @notice This contract creates "hardened" metamorphic contracts, or contracts
 * that can be redeployed with new code to the same address, with additional
 * protections against creating non-metamorphic contracts or losing any balance
 * held by the contract when it is destroyed. It does so by first setting the
 * desired contract initialization code in temporary storage. Next, a vault
 * contract corresponding to the target address is checked for a balance, and if
 * one exists it will be sent to the address of an intermediate deployer, or a
 * transient contract with fixed, non-deterministic initialization code. Once
 * deployed via CREATE2, the transient contract retrieves the initialization
 * code from storage and uses it to deploy the contract via CREATE, forwarding
 * the entire balance to the new contract, and then SELFDESTRUCTs. Finally, the
 * contract prelude is checked to ensure that it is properly destructible and
 * that it designates the vault as the forwarding address. Once the contract
 * undergoes metamorphosis, all existing storage will be deleted and any balance
 * will be forwarded to the vault that can then resupply the metamorphic
 * contract upon redeployment.
 * @dev This contract has not yet been fully tested or audited - proceed with
 * abundant caution and please share any exploits or optimizations you discover.
 * Also, bear in mind that any initialization code provided to the contract must
 * contain the proper prelude, or initial sequence, with a length of 44 bytes:
 *
 *  `0x6e03212eb796dee588acdbbbd777d4e73318602b5773 + vault_address + 0xff5b`
 *
 * For the required vault address, use `findVaultContractAddress(bytes32 salt)`.
 * Any initialization code generated by Solidity or another compiler will need
 * to have the stack items provided to JUMP, JUMPI, and CODECOPY altered
 * appropriately upon inserting this code, and may also need to alter some PC
 * operations (especially if it is not Solidity code). Be aware that contracts
 * are still accessible after they have been scheduled for deletion until the
 * transaction is completed, and that ether may still be sent to them - as the
 * funds forwarding step is performed immediately, not as part of the
 * transaction substate with the account removal. If those funds do not move to
 * a non-destructing account by the end of the transaction, they will be
 * irreversibly burned. Lastly, due to the mechanics of SELFDESTRUCT, a contract
 * cannot be destroyed and redeployed in a single transaction - to avoid
 * "downtime" of the contract, consider utilizing multiple contracts and having
 * the callers determine the current contract by using EXTCODEHASH.
 */
contract MetapodUpdated {
    // fires when a metamorphic contract is deployed.
    event Metamorphosed(address metamorphicContract, bytes32 salt);

    // fires when a metamorphic contract is destroyed.
    event Cocooned(address metamorphicContract, bytes32 salt);

    // initialization code for transient contract to deploy metamorphic contracts.
    /* ##  op  operation        [stack] <memory> {return_buffer} *contract_deploy*
       00  58  PC               [0]
       01  60  PUSH1 0x1c       [0, 28]
       03  59  MSIZE            [0, 28, 0]
       04  58  PC               [0, 28, 0, 4]
       05  59  MSIZE            [0, 28, 0, 4, 0]
       06  92  SWAP3            [0, 0, 0, 4, 28]
       07  33  CALLER           [0, 0, 0, 4, 28, caller]
       08  5a  GAS              [0, 0, 0, 4, 28, caller, gas]
       09  63  PUSH4 0x57b9f523 [0, 0, 0, 4, 28, caller, gas, selector]
       14  59  MSIZE            [0, 0, 0, 4, 28, caller, gas, selector, 0]
       15  52  MSTORE           [0, 0, 0, 4, 28, caller, gas] <selector>
       16  fa  STATICCALL       [0, 1 => success] {init_code}
       17  50  POP              [0]
       18  60  PUSH1 0x40       [0, 64]
       20  30  ADDRESS          [0, 64, address]
       21  31  BALANCE          [0, 64, balance]
       22  81  DUP2             [0, 64, balance, 64]
       23  3d  RETURNDATASIZE   [0, 64, balance, 64, size]
       24  03  SUB              [0, 64, balance, size - 64]
       25  83  DUP4             [0, 64, balance, size - 64, 0]
       26  92  SWAP3            [0, 0, balance, size - 64, 64]
       27  81  DUP2             [0, 0, balance, size - 64, 64, size - 64]
       28  94  SWAP5            [size - 64, 0, balance, size - 64, 64, 0]
       29  3e  RETURNDATACOPY   [size - 64, 0, balance] <init_code>
       30  f0  CREATE           [contract_address or 0] *init_code*
       31  80  DUP1             [contract_address or 0, contract_address or 0]
       32  15  ISZERO           [contract_address or 0, 0 or 1]
       33  60  PUSH1 0x25       [contract_address or 0, 0 or 1, 37]
       35  57  JUMPI            [contract_address]
       36  ff  SELFDESTRUCT     []
       37  5b  JUMPDEST         [0]
       38  80  DUP1             [0, 0]
       39  fd  REVERT           []
    */
    bytes private constant TRANSIENT_CONTRACT_INITIALIZATION_CODE = (
    hex"58601c59585992335a6357b9f5235952fa5060403031813d03839281943ef08015602557ff5b80fd"
    );

    // store the hash of the initialization code for transient contracts as well.
    bytes32 private constant TRANSIENT_CONTRACT_INITIALIZATION_CODE_HASH = bytes32(
        0xb7d11e258d6663925ce8e43f07ba3b7792a573ecc2fd7682d01f8a70b2223294
    );

    // the "empty data hash" is used to determine if the vault has been deployed.
    bytes32 private constant EMPTY_DATA_HASH = bytes32(
        0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470
    );

    // maintain a temporary storage slot for metamorphic initialization code.
    bytes private _initCode;

    constructor() public {
        // ensure that the deployment address is correct.
        // factory: 0x2415e7092bC80213E128536E6B22a54c718dC67A
        // caller: 0xaFD79DB96D018f333deb9ac821cc170F5cc81Ea8
        // init code hash: 0x8954ff8965dbf871b7b4f49acc85a2a7c96c93ebc16ba59a4d07c52d8d0b6ec2
        // salt: 0xafd79db96d018f333deb9ac821cc170f5cc81ea810f74f2d75490b0486060000
        require(
            address(this) == address(0x0165878A594ca255338adfa4d48449f69242Eb8F),
            "Incorrect deployment address."
        );

        // ensure the transient initialization code hash constant value is correct.
        require(
            keccak256(
                abi.encodePacked(TRANSIENT_CONTRACT_INITIALIZATION_CODE)
            ) == TRANSIENT_CONTRACT_INITIALIZATION_CODE_HASH,
            "Incorrect hash for transient initialization code."
        );

        // ensure the empty data hash constant value is correct.
        require(
        keccak256(abi.encodePacked(hex"")) == EMPTY_DATA_HASH,
        "Incorrect hash for empty data."
        );
    }

    /**
     * @dev Deploy a metamorphic contract by submitting a given salt or nonce
   * along with the initialization code to a transient contract which will then
   * deploy the metamorphic contract before immediately SELFDESTRUCTing. To
   * replace the metamorphic contract, call destroy() with the same salt value,
   * then call with the same salt value and new initialization code (be aware
   * that all existing state will be wiped from the contract).
   * @param identifier uint96 The last twelve bytes of the salt that will be
   * passed into the CREATE2 call (with the first twenty bytes of the salt set
   * to `msg.sender`) and thus will determine the resulant address of the
   * metamorphic contract.
   * @param initializationCode bytes The initialization code for the metamorphic
   * contract that will be deployed by the transient contract.
   * @return The address of the deployed metamorphic contract.
   */
    function deploy(
        uint96 identifier,
        bytes calldata initializationCode
    ) external payable returns (address metamorphicContract) {
        // compute the salt using the supplied identifier.
        bytes32 salt = _getSalt(identifier);

        // store the initialization code to be retrieved by the transient contract.
        _initCode = initializationCode;

        // get vault contract and provide any funds therein to transient contract.
        address vaultContract = _triggerVaultFundsRelease(salt);

        // declare variable to verify successful transient contract deployment.
        address transientContract;

        // move transient contract initialization code into memory.
        bytes memory initCode = TRANSIENT_CONTRACT_INITIALIZATION_CODE;

        // load transient contract init data and size, then deploy via CREATE2.
        assembly { /* solhint-disable no-inline-assembly */
            let encoded_data := add(0x20, initCode) // load initialization code.
            let encoded_size := mload(initCode)     // load the init code's length.
            transientContract := create2(           // call CREATE2 with 4 arguments.
            callvalue,                            // forward any supplied endowment.
            encoded_data,                         // pass in initialization code.
            encoded_size,                         // pass in init code's length.
            salt                                  // pass in the salt value.
            )
        } /* solhint-enable no-inline-assembly */

        // ensure that the contracts were successfully deployed.
        require(transientContract != address(0), "Failed to deploy contract.");

        // get the address of the deployed metamorphic contract.
        metamorphicContract = _getMetamorphicContractAddress(transientContract);

        // ensure that the deployed runtime code has the required prelude.
        _verifyPrelude(metamorphicContract, _getPrelude(vaultContract));

        // clear the supplied initialization code from temporary storage.
        delete _initCode;

        // emit an event to signify that the contract was successfully deployed.
        emit Metamorphosed(metamorphicContract, salt);
    }

    /**
     * @dev Destroy a metamorphic contract by calling into it, which will trigger
   * a SELFDESTRUCT and forward all funds to the designated vault contract. Be
   * aware that all existing state will be wiped from the contract.
   * @param identifier uint96 The last twelve bytes of the salt that was passed
   * into the CREATE2 call (with the first twenty bytes of the salt set to
   * `msg.sender`) that determined resulant address of the metamorphic contract.
   */
    function destroy(uint96 identifier) external {
        // compute the salt using the supplied identifier.
        bytes32 salt = _getSalt(identifier);

        // determine the address of the metamorphic contract.
        address metamorphicContract = _getMetamorphicContractAddress(
            _getTransientContractAddress(salt)
        );

        // call it to trigger a SELFDESTRUCT that forwards any funds to the vault.
        metamorphicContract.call(""); /* solhint-disable-line avoid-low-level-calls */

        // emit an event to signify that the contract was scheduled for deletion.
        emit Cocooned(metamorphicContract, salt);
    }

    /**
     * @dev Recover the funds from a metamorphic contract, the associated vault,
   * and the associated transient contract by deploying a dedicated metamorphic
   * contract that will forward funds to `msg.sender` and immediately
   * SELFDESTRUCT. The contract must be "cocooned" or else it will fail.
   * @param identifier uint96 The last twelve bytes of the salt that was passed
   * into the CREATE2 call (with the first twenty bytes of the salt set to
   * `msg.sender`) that determined resulant address of the metamorphic contract.
   */
    function recover(uint96 identifier) external {
        // compute the salt using the supplied identifier.
        bytes32 salt = _getSalt(identifier);

        // trigger the vault contract to forward funds to the transient contract.
        _triggerVaultFundsRelease(salt);

        // construct recovery contract initialization code and set in temp storage.
        _initCode = abi.encodePacked(
            bytes2(0x5873),  // PC PUSH20
            msg.sender,      // <the caller is the recipient of funds>
            bytes13(0x905959593031856108fcf150ff)
        // SWAP1 MSIZEx3 ADDRESS BALANCE DUP6 PUSH2 2300 CALL POP SELFDESTRUCT
        );

        // declare variable to verify successful transient contract deployment.
        address transientContract;

        // move transient contract initialization code into memory.
        bytes memory initCode = TRANSIENT_CONTRACT_INITIALIZATION_CODE;

        // load transient contract init data and size, then deploy via CREATE2.
        assembly { /* solhint-disable no-inline-assembly */
            let encoded_data := add(0x20, initCode) // load initialization code.
            let encoded_size := mload(initCode)     // load the init code's length.
            transientContract := create2(           // call CREATE2 with 4 arguments.
            callvalue,                            // forward any supplied endowment.
            encoded_data,                         // pass in initialization code.
            encoded_size,                         // pass in init code's length.
            salt                                  // pass in the salt value.
            )
        } /* solhint-enable no-inline-assembly */

        // ensure that the recovery contract was successfully deployed.
        require(
            transientContract != address(0),
            "Recovery failed - ensure that the contract has been destroyed."
        );

        // clear recovery contract initialization code from temporary storage.
        delete _initCode;
    }

    /**
     * @dev View function for retrieving the initialization code for a given
   * metamorphic contract to deploy via a transient contract. Called by the
   * constructor of each transient contract - not meant to be called by users.
   * @return The initialization code to use to deploy the metamorphic contract.
   */
    function getInitializationCode() external view returns (
        bytes memory initializationCode
    ) {
        // return the current initialization code from temporary storage.
        initializationCode = _initCode;
    }

    /**
     * @dev Compute the address of the transient contract that will be created
   * upon submitting a given salt to the contract.
   * @param salt bytes32 The nonce passed into CREATE2 when deploying the
   * transient contract, composed of caller ++ identifier.
   * @return The address of the corresponding transient contract.
   */
    function findTransientContractAddress(
        bytes32 salt
    ) external pure returns (address transientContract) {
        // determine the address where the transient contract will be deployed.
        transientContract = _getTransientContractAddress(salt);
    }

    /**
     * @dev Compute the address of the metamorphic contract that will be created
   * upon submitting a given salt to the contract.
   * @param salt bytes32 The nonce used to create the transient contract that
   * deploys the metamorphic contract, composed of caller ++ identifier.
   * @return The address of the corresponding metamorphic contract.
   */
    function findMetamorphicContractAddress(
        bytes32 salt
    ) external pure returns (address metamorphicContract) {
        // determine the address of the metamorphic contract.
        metamorphicContract = _getMetamorphicContractAddress(
            _getTransientContractAddress(salt)
        );
    }

    /**
     * @dev Compute the address of the vault contract that will be set as the
   * recipient of funds from the metamorphic contract when it is destroyed.
   * @param salt bytes32 The nonce used to create the transient contract that
   * deploys the metamorphic contract, composed of caller ++ identifier.
   * @return The address of the corresponding vault contract.
   */
    function findVaultContractAddress(
        bytes32 salt
    ) external pure returns (address vaultContract) {
        vaultContract = _getVaultContractAddress(
            _getVaultContractInitializationCode(
                _getTransientContractAddress(salt)
            )
        );
    }

    /**
     * @dev View function for retrieving the prelude that will be required for any
   * metamorphic contract deployed via a specific salt.
   * @param salt bytes32 The nonce used to create the transient contract that
   * deploys the metamorphic contract, composed of caller ++ identifier.
   * @return The prelude that will be need to be present at the start of the
   * deployed runtime code for any metamorphic contracts deployed using the
   * provided salt.
   */
    function getPrelude(bytes32 salt) external pure returns (
        bytes memory prelude
    ) {
        // compute and return the prelude.
        prelude = _getPrelude(
            _getVaultContractAddress(
                _getVaultContractInitializationCode(
                    _getTransientContractAddress(salt)
                )
            )
        );
    }

    /**
     * @dev View function for retrieving the initialization code of metamorphic
   * contracts for purposes of verification.
   * @return The initialization code used to deploy transient contracts.
   */
    function getTransientContractInitializationCode() external pure returns (
        bytes memory transientContractInitializationCode
    ) {
        // return the initialization code used to deploy transient contracts.
        transientContractInitializationCode = (
        TRANSIENT_CONTRACT_INITIALIZATION_CODE
        );
    }

    /**
     * @dev View function for retrieving the keccak256 hash of the initialization
   * code of metamorphic contracts for purposes of verification.
   * @return The keccak256 hash of the initialization code used to deploy
   * transient contracts.
   */
    function getTransientContractInitializationCodeHash() external pure returns (
        bytes32 transientContractInitializationCodeHash
    ) {
        // return hash of initialization code used to deploy transient contracts.
        transientContractInitializationCodeHash = (
        TRANSIENT_CONTRACT_INITIALIZATION_CODE_HASH
        );
    }

    /**
     * @dev View function for calculating a salt given a particular caller and
   * identifier.
   * @param identifier bytes12 The last twelve bytes of the salt (the first
   * twenty bytes are set to `msg.sender`).
   * @return The salt that will be supplied to CREATE2 upon providing the given
   * identifier from the calling account.
   */
    function getSalt(uint96 identifier) external view returns (bytes32 salt) {
        salt = _getSalt(identifier);
    }

    /**
     * @dev Internal view function for calculating a salt given a particular
   * caller and identifier.
   * @param identifier bytes12 The last twelve bytes of the salt (the first
   * twenty bytes are set to `msg.sender`).
   * @return The salt that will be supplied to CREATE2.
   */
    function _getSalt(uint96 identifier) internal view returns (bytes32 salt) {
        assembly { /* solhint-disable no-inline-assembly */
            salt := or(shl(96, caller), identifier) // caller: first 20, ID: last 12
        } /* solhint-enable no-inline-assembly */
    }

    /**
     * @dev Internal function for determining the required prelude for metamorphic
   * contracts deployed through the factory based on the corresponding vault
   * contract.
   * @param vaultContract address The address of the vault contract.
   * @return The prelude that will be required for given a vault contract.
   */
    function _getPrelude(
        address vaultContract
    ) internal pure returns (bytes memory prelude) {
        prelude = abi.encodePacked(
        // PUSH15 <this> CALLER XOR PUSH1 43 JUMPI PUSH20
            bytes27(0x730165878A594ca255338adfa4d48449f69242Eb8F331860305773),
            vaultContract, // <vault is the approved SELFDESTRUCT recipient>
            bytes2(0xff5b) // SELFDESTRUCT JUMPDEST
        );
    }

    /**
     * @dev Internal function for determining if deployed metamorphic contract has
   * the necessary prelude at the start of its runtime code. The prelude ensures
   * that the contract can be destroyed by a call originating from this contract
   * and that any funds will be forwarded to the corresponding vault contract.
   * @param metamorphicContract address The address of the metamorphic contract.
   * @param prelude bytes The prelude that must be present on the contract.
   */
    function _verifyPrelude(
        address metamorphicContract,
        bytes memory prelude
    ) internal view {
        // get the first 44 bytes of metamorphic contract runtime code.
        bytes memory runtimeHeader;

        assembly { /* solhint-disable no-inline-assembly */
        // set and update the pointer based on the size of the runtime header.
            runtimeHeader := mload(0x40)
            mstore(0x40, add(runtimeHeader, 0x60))

        // store the runtime code and length in memory.
            mstore(runtimeHeader, 49)
            extcodecopy(metamorphicContract, add(runtimeHeader, 0x20), 0, 49)
        } /* solhint-enable no-inline-assembly */
        console.logBytes(prelude);
        console.logBytes(runtimeHeader);
        // ensure that the contract's runtime code has the correct initial sequence.
        require(
            keccak256(
                abi.encodePacked(prelude)
            ) == keccak256(
            abi.encodePacked(runtimeHeader)
        ),
            "Deployed runtime code does not have the required prelude."
        );
    }

    /**
     * @dev Internal function for determining if a vault contract has a balance
   * and tranferring the balance to the corresponding transient contract if so.
   * This is achieved via deploying the vault contract if no contract exists yet
   * or by calling the contract if it has already been deployed.
   * @param salt bytes32 The nonce used to create the transient contract that
   * deploys the metamorphic contract associated with a corresponding vault.
   * @return The address of the vault contract.
   */
    function _triggerVaultFundsRelease(
        bytes32 salt
    ) internal returns (address vaultContract) {
        // determine the address of the transient contract.
        address transientContract = _getTransientContractAddress(salt);

        // determine the initialization code of the vault contract.
        bytes memory vaultContractInitCode = _getVaultContractInitializationCode(
            transientContract
        );

        // determine the address of the vault contract.
        vaultContract = _getVaultContractAddress(vaultContractInitCode);

        // determine if the vault has a balance.
        if (vaultContract.balance > 0) {
            // determine if the vault has already been deployed.
            bytes32 vaultContractCodeHash;

            assembly { /* solhint-disable no-inline-assembly */
                vaultContractCodeHash := extcodehash(vaultContract)
            } /* solhint-enable no-inline-assembly */

            // if it hasn't been deployed, deploy it to send funds to transient.
            if (vaultContractCodeHash == EMPTY_DATA_HASH) {
                assembly { /* solhint-disable no-inline-assembly */
                    let encoded_data := add(0x20, vaultContractInitCode) // init code.
                    let encoded_size := mload(vaultContractInitCode)     // init length.
                    let _ := create2(                   // call CREATE2.
                    0,                                // do not supply any endowment.
                    encoded_data,                     // pass in initialization code.
                    encoded_size,                     // pass in init code's length.
                    0                                 // pass in zero as the salt value.
                    )
                } /* solhint-enable no-inline-assembly */
                // otherwise, just call it which will also send funds to transient.
            } else {
                vaultContract.call(""); /* solhint-disable-line avoid-low-level-calls */
            }
        }
    }

    /**
     * @dev Internal view function for calculating a transient contract address
   * given a particular salt.
   * @param salt bytes32 The nonce used to create the transient contract.
   * @return The address of the transient contract.
   */
    function _getTransientContractAddress(
        bytes32 salt
    ) internal pure returns (address transientContract) {
        // determine the address of the transient contract.
        transientContract = address(
            uint160(                      // downcast to match the address type.
                uint256(                    // convert to uint to truncate upper digits.
                    keccak256(                // compute the CREATE2 hash using 4 inputs.
                        abi.encodePacked(       // pack all inputs to the hash together.
                            hex"ff",              // start with 0xff to distinguish from RLP.
                            address(0x0165878A594ca255338adfa4d48449f69242Eb8F), // this.
                            salt,                 // pass in the supplied salt value.
                            TRANSIENT_CONTRACT_INITIALIZATION_CODE_HASH // the init code hash.
                        )
                    )
                )
            )
        );
    }

    /**
     * @dev Internal view function for calculating a metamorphic contract address
   * that has been deployed via a transient contract given the address of the
   * transient contract.
   * @param transientContract address The address of the transient contract.
   * @return The address of the metamorphic contract.
   */
    function _getMetamorphicContractAddress(
        address transientContract
    ) internal pure returns (address metamorphicContract) {
        // determine the address of the metamorphic contract.
        metamorphicContract = address(
            uint160(                          // downcast to match the address type.
                uint256(                        // set to uint to truncate upper digits.
                    keccak256(                    // compute CREATE hash via RLP encoding.
                        abi.encodePacked(           // pack all inputs to the hash together.
                            bytes2(0xd694),           // first two RLP bytes.
                            transientContract,        // called by the transient contract.
                            byte(0x01)                // nonce begins at 1 for contracts.
                        )
                    )
                )
            )
        );
    }

    /**
     * @dev Internal view function for calculating a initialization code for a
   * given vault contract based on the corresponding transient contract.
   * @param transientContract address The address of the transient contract.
   * @return The initialization code for the vault contract.
   */
    function _getVaultContractInitializationCode(
        address transientContract
    ) internal pure returns (bytes memory vaultContractInitializationCode) {
        vaultContractInitializationCode = abi.encodePacked(
        // PC PUSH15 <this> CALLER XOR PC JUMPI MSIZEx3 ADDRESS BALANCE PUSH20
            bytes27(0x586e03212eb796dee588acdbbbd777d4e733185857595959303173),
        // the transient contract is the recipient of funds
            transientContract,
        // GAS CALL PUSH1 49 MSIZE DUP2 MSIZEx2 CODECOPY RETURN
            bytes10(0x5af160315981595939f3)
        );
    }

    /**
     * @dev Internal view function for calculating a vault contract address given
   * the initialization code for the vault contract.
   * @param vaultContractInitializationCode bytes The initialization code of the
   * vault contract.
   * @return The address of the vault contract.
   */
    function _getVaultContractAddress(
        bytes memory vaultContractInitializationCode
    ) internal pure returns (address vaultContract) {
        // determine the address of the vault contract.
        vaultContract = address(
            uint160(                      // downcast to match the address type.
                uint256(                    // convert to uint to truncate upper digits.
                    keccak256(                // compute the CREATE2 hash using 4 inputs.
                        abi.encodePacked(       // pack all inputs to the hash together.
                            byte(0xff),           // start with 0xff to distinguish from RLP.
                            address(0x000000000003212eb796dEE588acdbBbD777D4E7), // this.
                            bytes32(0),           // leave the salt value set to zero.
                            keccak256(            // hash the supplied initialization code.
                                vaultContractInitializationCode
                            )
                        )
                    )
                )
            )
        );
    }
}