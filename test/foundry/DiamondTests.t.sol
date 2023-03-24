// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../src/SimpleDiamond/facet/SimpleERC20Facet.sol";
import "../../src/SimpleDiamond/facet/SimpleERC721Facet.sol";
import "../../src/SimpleDiamond/diamond/ERC721Diamond.sol";

contract DiamondTests is Test {
    SimpleERC20Facet erc20;
    SimpleERC721Facet erc721;
    ERC721Diamond diamond;

    function setUp() public {
        //        erc20 = new SimpleERC20Facet("FXT", "DIAMOND");
        //        erc721 = new SimpleERC721Facet("FXT", "DIAMOND");
        diamond = new ERC721Diamond(address(this));
    }

    function testOne() public {
        diamond.mintNFTs();
        (bool success1, bytes memory data1) = address(diamond).call(abi.encodeWithSignature("addLiquidity(uint256)", 500000000000));
        if (!success1){
        revert("asdf");
        }
    (bool success2, bytes memory data2) = address(diamond).call(abi.encodeWithSignature("balanceOf(address)", address(this)));
        console.log(success2);
        console.logBytes(data2);

    }
}
