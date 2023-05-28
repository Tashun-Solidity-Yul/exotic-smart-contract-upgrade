pragma solidity 0.5.6;


/**
 * @title ContractThree
 * @notice This is the first implementation of an example metamorphic contract.
 */
contract ContractThree {
    uint256 private _x;

    constructor(uint256 x_) public {
        _x = x_;
    }

    /**
     * @dev test function
   * @return 1 once initialized (otherwise 0)
   */
    function test() external view returns (uint256 value) {
        return _x;
    }

    /**
     * @dev initialize function
   */
    function initialize() public {
        _x = 1;
    }

    /**
     * @dev destroy function, allows for the metamorphic contract to be redeployed
   */
    function destroy() public {
        selfdestruct(msg.sender);
    }

    function test123() public view returns (uint256 value){return _x;}
}
