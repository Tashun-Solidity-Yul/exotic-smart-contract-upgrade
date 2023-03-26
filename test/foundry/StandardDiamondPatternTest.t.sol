// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../src/StandardDiamondPattern/Diamond.sol";
import "../../src/StandardDiamondPattern/facets/ERC20UpgradableFacet.sol";
import "../../src/StandardDiamondPattern/facets/ERC721UpgradableFacet.sol";
import {IDiamond} from "../../src/StandardDiamondPattern/interfaces/IDiamond.sol";
import "../../src/StandardDiamondPattern/facets/facetUpgrade/ERC20UpgradableFacetV2.sol";

contract StandardDiamondPatternTest is Test {
    Diamond diamond;
    address user1;
    address user2;
    address user3;
    address erc20;
    address erc721;

    function setUp() public {
        user1 = vm.addr(1);
        user2 = vm.addr(2);
        user3 = vm.addr(3);

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](2);
        erc20 = address(new ERC20UpgradableFacet());
        cuts[0].facetAddress = erc20;
        cuts[0].action = IDiamond.FacetCutAction.Add;

        bytes4[] memory functionSelectors = new bytes4[](4);
        functionSelectors[0] = ERC20UpgradableFacet.name.selector;
        functionSelectors[1] = ERC20UpgradableFacet.balanceOf.selector;
        functionSelectors[2] = ERC20UpgradableFacet.transfer.selector;
        functionSelectors[3] = ERC20UpgradableFacet.buyERC20Tokens.selector;
        cuts[0].functionSelectors = functionSelectors;

        erc721 = address(new ERC721UpgradableFacet());
        cuts[1].facetAddress = erc721;
        cuts[1].action = IDiamond.FacetCutAction.Add;

        functionSelectors = new bytes4[](7);
        functionSelectors[0] = ERC721UpgradableFacet.buyNonFungibleToken.selector;
        functionSelectors[1] = ERC721UpgradableFacet.balanceOfNFT.selector;
        functionSelectors[2] = ERC721UpgradableFacet.ownerOf.selector;
        functionSelectors[3] = ERC721UpgradableFacet.symbol.selector;
        functionSelectors[4] = ERC721UpgradableFacet.tokenURI.selector;
        functionSelectors[5] = ERC721UpgradableFacet.approve.selector;
        functionSelectors[6] = ERC721UpgradableFacet.transferFrom.selector;
        cuts[1].functionSelectors = functionSelectors;

        DiamondArgs memory da;
        da.init = address(0);
        da.initCalldata = new bytes(0);
        da.owner = user1;

        address[] memory facets = new address[](2);
        facets[0] = erc20;
        facets[1] = erc721;

        bytes[] memory b = new bytes[](2);
        b[0] = abi.encodeWithSignature("initialize(string,string)", "DIAMOND", "DMD");
        b[1] = abi.encodeWithSignature("initialize(string,string,address,address)", "DIAMOND", "DMD", erc20, user1);

        vm.prank(user1);
        diamond = new Diamond(cuts, da);
        vm.prank(user1);
        diamond.multiInit(facets, b);

        cuts = new IDiamondCut.FacetCut[](1);
        cuts[0].facetAddress = address(diamond);
        cuts[0].action = IDiamond.FacetCutAction.Add;
        functionSelectors = new bytes4[](10);
        functionSelectors[0] = IDiamondLoupe.facetAddress.selector;
        functionSelectors[1] = IDiamondCut.diamondCut.selector;
        functionSelectors[2] = IERC173.transferOwnership.selector;
        functionSelectors[3] = IDiamondLoupe.facets.selector;
        functionSelectors[4] = IERC173.owner.selector;
        functionSelectors[5] = DiamondInit.init.selector;
        functionSelectors[6] = IDiamondLoupe.facetAddresses.selector;
        functionSelectors[7] = IDiamondLoupe.facetFunctionSelectors.selector;
        functionSelectors[8] = DiamondMultiInit.multiInit.selector;
        functionSelectors[9] = IERC165.supportsInterface.selector;

        cuts[0].functionSelectors = functionSelectors;
        vm.prank(user1);
        diamond.diamondCut(cuts, address(0), new bytes(0));

    }

    function testERC20Name() public {
        (bool nameSuccess, bytes memory nameData) = address(diamond).call(abi.encodeWithSignature("name()"));
        assertTrue(nameSuccess);
        assertEq(abi.decode(nameData, (string)), "DIAMOND");
    }

    function testERC20Balance() public {
        (bool balanceSuccess, bytes memory balanceData) = address(diamond).call(abi.encodeWithSignature("balanceOf(address)", user1));
        assertTrue(balanceSuccess);
        assertEq(abi.decode(balanceData, (uint256)), 10_000_000);
    }

    function testERC20Transfer() public {
        vm.prank(user1);
        (bool transferSuccess,) = address(diamond).call(abi.encodeWithSignature("transfer(address,uint256)", user2, 1000));
        assertTrue(transferSuccess);

        (bool balanceSuccess, bytes memory balanceData) = address(diamond).call(abi.encodeWithSignature("balanceOf(address)", user2));
        assertTrue(balanceSuccess);
        assertEq(abi.decode(balanceData, (uint256)), 1000);
    }

    function testERC20BuyERC20Tokens() public {
        vm.prank(user2);
        vm.deal(user2, 1 ether);
        (bool transferSuccess,) = address(diamond).call{value : 1 ether}(abi.encodeWithSignature("buyERC20Tokens()", user2, 1000));
        assertTrue(transferSuccess);

        (bool balanceSuccess, bytes memory balanceData) = address(diamond).call(abi.encodeWithSignature("balanceOf(address)", user2));
        assertTrue(balanceSuccess);
        assertEq(abi.decode(balanceData, (uint256)), 1000 ether);
    }


    function testERC721BuyNonFungibleToken() public {
        vm.prank(user2);
        vm.deal(user2, 1 ether);
        (bool transferSuccess,) = address(diamond).call{value : 1 ether}(abi.encodeWithSignature("buyERC20Tokens()", user2, 1000));
        assertTrue(transferSuccess);

        (bool balanceSuccess, bytes memory balanceData) = address(diamond).call(abi.encodeWithSignature("balanceOf(address)", user2));
        assertTrue(balanceSuccess);
        assertEq(abi.decode(balanceData, (uint256)), 1000 ether);

        vm.prank(user2);
        vm.deal(user2, 1 ether);
        (bool mintSuccess,) = address(diamond).call(abi.encodeWithSignature("buyNonFungibleToken(uint256)", 200));
        assertTrue(mintSuccess);

        (bool balanceSuccess2, bytes memory balanceData2) = address(diamond).call(abi.encodeWithSignature("balanceOf(address)", user2));
        assertTrue(balanceSuccess2);
        assertEq(abi.decode(balanceData2, (uint256)), 990 ether);
    }


    function testERC721BalanceOfNFT() public {
        vm.prank(user2);
        vm.deal(user2, 1 ether);
        (bool transferSuccess,) = address(diamond).call{value : 1 ether}(abi.encodeWithSignature("buyERC20Tokens()", user2, 1000));
        assertTrue(transferSuccess);

        (bool balanceSuccess, bytes memory balanceData) = address(diamond).call(abi.encodeWithSignature("balanceOf(address)", user2));
        assertTrue(balanceSuccess);
        assertEq(abi.decode(balanceData, (uint256)), 1000 ether);

        vm.prank(user2);
        vm.deal(user2, 1 ether);
        (bool mintSuccess,) = address(diamond).call(abi.encodeWithSignature("buyNonFungibleToken(uint256)", 200));
        assertTrue(mintSuccess);

        (bool balanceSuccess2, bytes memory balanceData2) = address(diamond).call(abi.encodeWithSignature("balanceOf(address)", user2));
        assertTrue(balanceSuccess2);
        assertEq(abi.decode(balanceData2, (uint256)), 990 ether);

        (bool balanceSuccess3, bytes memory balanceData3) = address(diamond).call(abi.encodeWithSignature("balanceOfNFT(address)", user2));
        assertTrue(balanceSuccess3);
        assertEq(abi.decode(balanceData3, (uint256)), 200);
    }

    function testERC721BalanceOfNFTOne() public {
        vm.prank(user2);
        vm.deal(user2, 1 ether);
        (bool transferSuccess,) = address(diamond).call{value : 1 ether}(abi.encodeWithSignature("buyERC20Tokens()", user2, 1000));
        assertTrue(transferSuccess);

        (bool balanceSuccess, bytes memory balanceData) = address(diamond).call(abi.encodeWithSignature("balanceOf(address)", user2));
        assertTrue(balanceSuccess);
        assertEq(abi.decode(balanceData, (uint256)), 1000 ether);

        vm.prank(user2);
        vm.deal(user2, 1 ether);
        (bool mintSuccess,) = address(diamond).call(abi.encodeWithSignature("buyNonFungibleToken(uint256)", 1));
        assertTrue(mintSuccess);

        (bool balanceSuccess2, bytes memory balanceData2) = address(diamond).call(abi.encodeWithSignature("balanceOf(address)", user2));
        assertTrue(balanceSuccess2);
        assertEq(abi.decode(balanceData2, (uint256)), 1000 ether - 50_000_000_000_000_000);

        (bool balanceSuccess3, bytes memory balanceData3) = address(diamond).call(abi.encodeWithSignature("balanceOfNFT(address)", user2));
        assertTrue(balanceSuccess3);
        assertEq(abi.decode(balanceData3, (uint256)), 1);
    }

    function testERC721TransferFrom() public {
        vm.prank(user2);
        vm.deal(user2, 1 ether);
        (bool transferSuccess,) = address(diamond).call{value : 1 ether}(abi.encodeWithSignature("buyERC20Tokens()", user2, 1000));
        assertTrue(transferSuccess);

        (bool balanceSuccess, bytes memory balanceData) = address(diamond).call(abi.encodeWithSignature("balanceOf(address)", user2));
        assertTrue(balanceSuccess);
        assertEq(abi.decode(balanceData, (uint256)), 1000 ether);

        vm.prank(user2);
        vm.deal(user2, 1 ether);
        (bool mintSuccess,) = address(diamond).call(abi.encodeWithSignature("buyNonFungibleToken(uint256)", 200));
        assertTrue(mintSuccess);

        (bool balanceSuccess2, bytes memory balanceData2) = address(diamond).call(abi.encodeWithSignature("balanceOf(address)", user2));
        assertTrue(balanceSuccess2);
        assertEq(abi.decode(balanceData2, (uint256)), 990 ether);

        (bool balanceSuccess3, bytes memory balanceData3) = address(diamond).call(abi.encodeWithSignature("balanceOfNFT(address)", user2));
        assertTrue(balanceSuccess3);
        assertEq(abi.decode(balanceData3, (uint256)), 200);


        (bool ownerOfSuccess, bytes memory ownerOfData) = address(diamond).call(abi.encodeWithSignature("ownerOf(uint256)", 99));
        assertTrue(ownerOfSuccess);
        assertEq(abi.decode(ownerOfData, (address)), user2);

        vm.prank(user2);
        (bool approveSuccess,) = address(diamond).call(abi.encodeWithSignature("approve(address,uint256)", user3, 99));
        assertTrue(balanceSuccess3);

        vm.prank(user3);
        (bool transferFromSuccess,) = address(diamond).call(abi.encodeWithSignature("transferFrom(address,address,uint256)", user2, user3, 99));
        assertEq(transferFromSuccess, true);

        (bool ownerOfSuccess2, bytes memory ownerOfData2) = address(diamond).call(abi.encodeWithSignature("ownerOf(uint256)", 99));
        assertTrue(ownerOfSuccess2);
        assertEq(abi.decode(ownerOfData2, (address)), user3);
    }

    function testDiamondFacetsFunction() public {
        assertEq((diamond.facets()[0]).facetAddress, erc20);
        assertEq((diamond.facets()[0]).functionSelectors[0], ERC20UpgradableFacet.name.selector);
        assertEq((diamond.facets()[0]).functionSelectors[1], ERC20UpgradableFacet.balanceOf.selector);
        assertEq((diamond.facets()[0]).functionSelectors[2], ERC20UpgradableFacet.transfer.selector);
        assertEq((diamond.facets()[0]).functionSelectors[3], ERC20UpgradableFacet.buyERC20Tokens.selector);

        assertEq((diamond.facets()[1]).facetAddress, erc721);
        assertEq((diamond.facets()[1]).functionSelectors[0], ERC721UpgradableFacet.buyNonFungibleToken.selector);
        assertEq((diamond.facets()[1]).functionSelectors[1], ERC721UpgradableFacet.balanceOfNFT.selector);
        assertEq((diamond.facets()[1]).functionSelectors[2], ERC721UpgradableFacet.ownerOf.selector);
        assertEq((diamond.facets()[1]).functionSelectors[3], ERC721UpgradableFacet.symbol.selector);
        assertEq((diamond.facets()[1]).functionSelectors[4], ERC721UpgradableFacet.tokenURI.selector);
        assertEq((diamond.facets()[1]).functionSelectors[5], ERC721UpgradableFacet.approve.selector);
        assertEq((diamond.facets()[1]).functionSelectors[6], ERC721UpgradableFacet.transferFrom.selector);


        assertEq((diamond.facets()[2]).facetAddress, address(diamond));
        assertEq((diamond.facets()[2]).functionSelectors[0], IDiamondLoupe.facetAddress.selector);
        assertEq((diamond.facets()[2]).functionSelectors[1], IDiamondCut.diamondCut.selector);
        assertEq((diamond.facets()[2]).functionSelectors[2], IERC173.transferOwnership.selector);
        assertEq((diamond.facets()[2]).functionSelectors[3], IDiamondLoupe.facets.selector);
        assertEq((diamond.facets()[2]).functionSelectors[4], IERC173.owner.selector);
        assertEq((diamond.facets()[2]).functionSelectors[5], DiamondInit.init.selector);
        assertEq((diamond.facets()[2]).functionSelectors[6], IDiamondLoupe.facetAddresses.selector);
        assertEq((diamond.facets()[2]).functionSelectors[7], IDiamondLoupe.facetFunctionSelectors.selector);
        assertEq((diamond.facets()[2]).functionSelectors[8], DiamondMultiInit.multiInit.selector);
        assertEq((diamond.facets()[2]).functionSelectors[9], IERC165.supportsInterface.selector);

    }


    function testDiamondFacetFunctionSelectors() public {
        assertEq(diamond.facetFunctionSelectors(erc20)[0], ERC20UpgradableFacet.name.selector);
        assertEq(diamond.facetFunctionSelectors(erc20)[1], ERC20UpgradableFacet.balanceOf.selector);
        assertEq(diamond.facetFunctionSelectors(erc20)[2], ERC20UpgradableFacet.transfer.selector);
        assertEq(diamond.facetFunctionSelectors(erc20)[3], ERC20UpgradableFacet.buyERC20Tokens.selector);


        assertEq(diamond.facetFunctionSelectors(erc721)[0], ERC721UpgradableFacet.buyNonFungibleToken.selector);
        assertEq(diamond.facetFunctionSelectors(erc721)[1], ERC721UpgradableFacet.balanceOfNFT.selector);
        assertEq(diamond.facetFunctionSelectors(erc721)[2], ERC721UpgradableFacet.ownerOf.selector);
        assertEq(diamond.facetFunctionSelectors(erc721)[3], ERC721UpgradableFacet.symbol.selector);
        assertEq(diamond.facetFunctionSelectors(erc721)[4], ERC721UpgradableFacet.tokenURI.selector);
        assertEq(diamond.facetFunctionSelectors(erc721)[5], ERC721UpgradableFacet.approve.selector);
        assertEq(diamond.facetFunctionSelectors(erc721)[6], ERC721UpgradableFacet.transferFrom.selector);

        assertEq(diamond.facetFunctionSelectors(address(diamond))[0], IDiamondLoupe.facetAddress.selector);
        assertEq(diamond.facetFunctionSelectors(address(diamond))[1], IDiamondCut.diamondCut.selector);
        assertEq(diamond.facetFunctionSelectors(address(diamond))[2], IERC173.transferOwnership.selector);
        assertEq(diamond.facetFunctionSelectors(address(diamond))[3], IDiamondLoupe.facets.selector);
        assertEq(diamond.facetFunctionSelectors(address(diamond))[4], IERC173.owner.selector);
        assertEq(diamond.facetFunctionSelectors(address(diamond))[5], DiamondInit.init.selector);
        assertEq(diamond.facetFunctionSelectors(address(diamond))[6], IDiamondLoupe.facetAddresses.selector);
        assertEq(diamond.facetFunctionSelectors(address(diamond))[7], IDiamondLoupe.facetFunctionSelectors.selector);
        assertEq(diamond.facetFunctionSelectors(address(diamond))[8], DiamondMultiInit.multiInit.selector);
        assertEq(diamond.facetFunctionSelectors(address(diamond))[9], IERC165.supportsInterface.selector);
    }

    function testFacetAddress() public {
        assertEq(diamond.facetAddress(ERC20UpgradableFacet.name.selector), erc20);
        assertEq(diamond.facetAddress(ERC20UpgradableFacet.balanceOf.selector), erc20);
        assertEq(diamond.facetAddress(ERC20UpgradableFacet.transfer.selector), erc20);
        assertEq(diamond.facetAddress(ERC20UpgradableFacet.buyERC20Tokens.selector), erc20);

        assertEq(diamond.facetAddress(ERC721UpgradableFacet.buyNonFungibleToken.selector), erc721);
        assertEq(diamond.facetAddress(ERC721UpgradableFacet.balanceOfNFT.selector), erc721);
        assertEq(diamond.facetAddress(ERC721UpgradableFacet.ownerOf.selector), erc721);
        assertEq(diamond.facetAddress(ERC721UpgradableFacet.symbol.selector), erc721);
        assertEq(diamond.facetAddress(ERC721UpgradableFacet.tokenURI.selector), erc721);
        assertEq(diamond.facetAddress(ERC721UpgradableFacet.approve.selector), erc721);
        assertEq(diamond.facetAddress(ERC721UpgradableFacet.transferFrom.selector), erc721);

        assertEq(diamond.facetAddress(IDiamondLoupe.facetAddress.selector), address(diamond));
        assertEq(diamond.facetAddress(IDiamondCut.diamondCut.selector), address(diamond));
        assertEq(diamond.facetAddress(IERC173.transferOwnership.selector), address(diamond));
        assertEq(diamond.facetAddress(IDiamondLoupe.facets.selector), address(diamond));
        assertEq(diamond.facetAddress(IERC173.owner.selector), address(diamond));
        assertEq(diamond.facetAddress(DiamondInit.init.selector), address(diamond));
        assertEq(diamond.facetAddress(IDiamondLoupe.facetAddresses.selector), address(diamond));
        assertEq(diamond.facetAddress(IDiamondLoupe.facetFunctionSelectors.selector), address(diamond));
        assertEq(diamond.facetAddress(DiamondMultiInit.multiInit.selector), address(diamond));
        assertEq(diamond.facetAddress(IERC165.supportsInterface.selector), address(diamond));

    }

    function testFacetAddresses() public {
        assertEq(diamond.facetAddresses()[0], erc20);
        assertEq(diamond.facetAddresses()[1], erc721);
        assertEq(diamond.facetAddresses()[2], address(diamond));
    }

    function testRemoveSelectors() public {

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);

        cuts[0].facetAddress = address(0);
        cuts[0].action = IDiamond.FacetCutAction.Remove;

        bytes4[] memory functionSelectors = new bytes4[](2);
        functionSelectors[0] = ERC20UpgradableFacet.name.selector;
        functionSelectors[1] = ERC20UpgradableFacet.buyERC20Tokens.selector;
        cuts[0].functionSelectors = functionSelectors;


        vm.prank(user1);
        diamond.diamondCut(cuts, address(0), new bytes(0));

        assertEq(diamond.facetAddress(ERC20UpgradableFacet.name.selector), address(0));
        assertEq(diamond.facetAddress(ERC20UpgradableFacet.buyERC20Tokens.selector), address(0));
        assertEq(diamond.facetAddress(ERC20UpgradableFacet.transfer.selector), erc20);
        assertEq(diamond.facetAddress(ERC20UpgradableFacet.balanceOf.selector), erc20);


    }

    function testReplaceSelector() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);

        cuts[0].facetAddress = erc20;
        cuts[0].action = IDiamond.FacetCutAction.Replace;

        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = ERC20UpgradableFacet.symbol.selector;
        cuts[0].functionSelectors = functionSelectors;


        vm.prank(user1);
        diamond.diamondCut(cuts, address(0), new bytes(0));

        cuts = new IDiamondCut.FacetCut[](1);

        cuts[0].facetAddress = erc721;
        cuts[0].action = IDiamond.FacetCutAction.Replace;

        functionSelectors = new bytes4[](1);
        functionSelectors[0] = ERC721UpgradableFacet.name.selector;
        cuts[0].functionSelectors = functionSelectors;


        vm.prank(user1);
        diamond.diamondCut(cuts, address(0), new bytes(0));
    }
    
    function upgradeERC20() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);

        cuts[0].facetAddress = address(0);
        cuts[0].action = IDiamond.FacetCutAction.Remove;

        bytes4[] memory functionSelectors = new bytes4[](4);
        functionSelectors[0] = ERC20UpgradableFacet.name.selector;
        functionSelectors[1] = ERC20UpgradableFacet.buyERC20Tokens.selector;
        functionSelectors[2] = ERC20UpgradableFacet.transfer.selector;
        functionSelectors[3] = ERC20UpgradableFacet.balanceOf.selector;
        cuts[0].functionSelectors = functionSelectors;


        vm.prank(user1);
        diamond.diamondCut(cuts, address(0), new bytes(0));

        assertEq(diamond.facetAddress(ERC20UpgradableFacet.name.selector), address(0));
        assertEq(diamond.facetAddress(ERC20UpgradableFacet.buyERC20Tokens.selector), address(0));
        assertEq(diamond.facetAddress(ERC20UpgradableFacet.transfer.selector), address(0));
        assertEq(diamond.facetAddress(ERC20UpgradableFacet.balanceOf.selector), address(0));


        erc20 = address(new ERC20UpgradableFacetV2());

        address[] memory facets = new address[](1);
        facets[0] = erc20;

        bytes[] memory b = new bytes[](1);
        b[0] = abi.encodeWithSignature("initialize(string,string)", "DIAMOND", "DMD");

        vm.prank(user1);
        diamond.multiInit(facets, b);


        // cuts diamond to add functionality
        cuts = new IDiamondCut.FacetCut[](1);

        cuts[0].facetAddress = erc20;
        cuts[0].action = IDiamond.FacetCutAction.Add;

        functionSelectors = new bytes4[](4);
        functionSelectors[0] = ERC20UpgradableFacet.name.selector;
        functionSelectors[1] = ERC20UpgradableFacet.buyERC20Tokens.selector;
        functionSelectors[2] = ERC20UpgradableFacet.transfer.selector;
        functionSelectors[3] = ERC20UpgradableFacet.balanceOf.selector;
        cuts[0].functionSelectors = functionSelectors;


        vm.prank(user1);
        diamond.diamondCut(cuts, address(0), new bytes(0));

        assertEq(diamond.facetAddress(ERC20UpgradableFacet.name.selector), erc20);

    }


}
