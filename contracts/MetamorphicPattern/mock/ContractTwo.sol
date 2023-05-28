pragma solidity 0.5.6;


/**
 * @title ContractTwo
 * @notice This is the second implementation of an example metamorphic contract.
 */
contract ContractTwo {
  event Paid(uint256 amount);

  uint256 private _x;


  function initialize() public {
    _x = 10;
  }

  /**
   * @dev Payable fallback function that emits an event logging the payment
   */
  function () external payable {
    if (msg.value > 0) {
      emit Paid(msg.value);
    }
  }

  /**
   * @dev Test function
   * @return 0 - storage is NOT carried over from the first implementation
   */
  function test() external view returns (uint256 value) {
    return _x;
  }

  function test9() external view returns (uint256 value) {
    return _x;
  }

  function test8() external view returns (uint256 value) {
    return _x;
  }

  function test7() external view returns (uint256 value) {
    return _x;
  }
  function test6() external view returns (uint256 value) {
    return _x;
  }
  function test5() external view returns (uint256 value) {
    return _x;
  }
  function test4() external view returns (uint256 value) {
    return _x;
  }
  function test3() external view returns (uint256 value) {
    return _x;
  }
  function test2() external view returns (uint256 value) {
    return _x;
  }
  function test1() external view returns (uint256 value) {
    return _x;
  }






}
