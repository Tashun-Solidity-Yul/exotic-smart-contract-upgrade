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
    address user1;
    address user2;

    function setUp() public {
        erc20 = new SimpleERC20Facet();
        erc721 = new SimpleERC721Facet();

        diamond = new ERC721Diamond(address(this), address(erc20), address(erc721));
        string memory mnemonic = "test test test test test test test test test test test junk";
        uint256 privateKey1 = vm.deriveKey(mnemonic, 0);
        user1 = vm.addr(privateKey1);
        user2 = vm.addr(1);
    }

    function testSetup() public {
        (bool nameSuccess, bytes memory nameData) = address(diamond).call(abi.encodeWithSignature("name()"));
        assertTrue(nameSuccess);
        assertEq(abi.decode(nameData, (string)), "DIAMOND");
        (bool symbolSuccess, bytes memory symbolData) = address(diamond).call(abi.encodeWithSignature("symbol()"));
        assertTrue(symbolSuccess);
        assertEq(abi.decode(symbolData, (string)), "FTX");

    }

    function testMintERC20() public {
        vm.prank(user1);
        (bool mintERC20SuccessUser1, bytes memory addLiqRetDataUser1) = address(diamond).call(abi.encodeWithSignature("addLiquidity(uint256)", 500000000000));
        assertTrue(mintERC20SuccessUser1);
        assertEq(addLiqRetDataUser1, "");

        vm.prank(user2);
        (bool mintERC20SuccessUser2, bytes memory addLiqRetDataUser2) = address(diamond).call(abi.encodeWithSignature("addLiquidity(uint256)", 500000000000));
        assertTrue(mintERC20SuccessUser2);
        assertEq(addLiqRetDataUser2, "");

        vm.prank(user1);
        (bool balanceOfSuccessUser1, bytes memory balanceUser1) = address(diamond).call(abi.encodeWithSignature("balanceOf(address)", user1));
        assertTrue(balanceOfSuccessUser1);
        assertEq(abi.decode(balanceUser1, (uint256)), 500000000000);

        vm.prank(user2);
        (bool balanceOfSuccessUser2, bytes memory balanceUser2) = address(diamond).call(abi.encodeWithSignature("balanceOf(address)", user1));
        assertTrue(balanceOfSuccessUser2);
        assertEq(abi.decode(balanceUser2, (uint256)), 500000000000);
    }

    function testMintERC721() public {
        vm.prank(user1);
        (bool mintERC20SuccessUser1, bytes memory addLiqRetDataUser1) = address(diamond).call(abi.encodeWithSignature("addLiquidity(uint256)", 500000000000));

        assertTrue(mintERC20SuccessUser1);
        assertEq(addLiqRetDataUser1, "");

        vm.prank(user2);
        (bool mintERC20SuccessUser2, bytes memory addLiqRetDataUser2) = address(diamond).call(abi.encodeWithSignature("addLiquidity(uint256)", 500000000000));
        assertTrue(mintERC20SuccessUser2);
        assertEq(addLiqRetDataUser2, "");

        vm.prank(user1);
        (bool balanceOfSuccessUser1, bytes memory balanceUser1) = address(diamond).call(abi.encodeWithSignature("balanceOf(address)", user1));
        assertTrue(balanceOfSuccessUser1);
        assertEq(abi.decode(balanceUser1, (uint256)), 500000000000);

        vm.prank(user1);
        (bool balanceOfSuccessUser2, bytes memory balanceUser2) = address(diamond).call(abi.encodeWithSignature("balanceOf(address)", user1));
        assertTrue(balanceOfSuccessUser2);
        assertEq(abi.decode(balanceUser2, (uint256)), 500000000000);

        vm.prank(user1);
        (bool mintERC721Token, bytes memory mintERC721TokenData) = address(diamond).call(abi.encodeWithSignature("mintANFT()"));
        assertTrue(mintERC721Token);

        vm.prank(user1);
        (bool balanceOfERC721, bytes memory mintERC721TokenData1) = address(diamond).call(abi.encodeWithSignature("balanceOfNFT(address)", user1));
        assertTrue(balanceOfERC721);
        assertEq(abi.decode(mintERC721TokenData1, (uint256)), 1);

    }
}
