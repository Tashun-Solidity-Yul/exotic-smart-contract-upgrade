//// SPDX-License-Identifier: UNLICENSED
//pragma solidity ^0.8.0;
//
//import "../storage/LibDiamondStorage.sol";
//import "../facet/SimpleERC721Facet.sol";
//import "../facet/SimpleERC20Facet.sol";
//import "forge-std/console.sol";
//
//
//contract UpgradableDiamond {
//    constructor(
//        address _contractOwner,
//        address erc20,
//        address erc721
//    ) {
//        LibDiamondStorage.setContractOwner(_contractOwner);
//        LibDiamondStorage.setNFTCost(500);
//        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();
//
//        IDiamondCut.FacetCut[] memory _diamondCut = new IDiamondCut.FacetCut[](1);
//        bytes4[] memory selectors = new bytes4[](4);
//
//        _diamondCut[0].facetAddress = address(erc721);
//        selectors[0] = SimpleERC721Facet.balanceOfNFT.selector;
//        selectors[1] = SimpleERC721Facet.transferFrom.selector;
//        selectors[2] = SimpleERC721Facet.approve.selector;
//        selectors[3] = SimpleERC721Facet.name.selector;
//        _diamondCut[0].functionSelectors = selectors;
//        LibDiamondStorage.diamondCut(_diamondCut, erc20, abi.encodeWithSignature("init(string,string)", "DIAMOND", "FTX"));
//
//        selectors = new bytes4[](4);
//
//        _diamondCut = new IDiamondCut.FacetCut[](1);
//        _diamondCut[0].facetAddress = address(erc20);
//        selectors[0] = SimpleERC20Facet.transfer.selector;
//        selectors[1] = SimpleERC20Facet.addLiquidity.selector;
//        selectors[2] = SimpleERC20Facet.balanceOf.selector;
//        selectors[3] = SimpleERC20Facet.symbol.selector;
//        _diamondCut[0].functionSelectors = selectors;
//
//
//        LibDiamondStorage.diamondCut(_diamondCut, erc721, abi.encodeWithSignature("init(string,string)", "DIAMOND", "FTX"));
//        ds.supportedInterfaces[0xd9b67a26] = true;
//    }
//
//
//    function mintANFT() external payable {
//        LibDiamondStorage.DiamondStorage storage ds;
//        bytes32 position = LibDiamondStorage.DIAMOND_STORAGE_POSITION;
//        assembly {
//            ds.slot := position
//        }
//
//        address facet = ds.selectorToFacetAndPosition[SimpleERC20Facet.transfer.selector].facetAddress;
//        (bool successTransfer, bytes memory data2) = facet.delegatecall(abi.encodeWithSignature("transfer(address,uint256)", address(this), LibDiamondStorage.getNFTCost()));
//
//        if (!successTransfer) {
//            revert("Unsuccessful Transfer");
//        }
//
//        facet = ds.selectorToFacetAndPosition[SimpleERC721Facet.balanceOfNFT.selector].facetAddress;
//
//        (bool successMint, bytes memory data1) = facet.delegatecall(abi.encodeWithSignature("mintToken(address)", msg.sender));
//        if (!successMint) {
//            revert("Unsuccessful Mint");
//        }
//
//    }
//
//    // Find facet for function that is called and execute the
//    // function if a facet is found and return any value.
//    fallback() external {
//        LibDiamondStorage.DiamondStorage storage ds;
//        bytes32 position = LibDiamondStorage.DIAMOND_STORAGE_POSITION;
//        assembly {
//            ds.slot := position
//        }
//        address facet = ds.selectorToFacetAndPosition[msg.sig].facetAddress;
//        require(facet != address(0), "Diamond: Function does not exist");
//        assembly {
//            calldatacopy(0, 0, calldatasize())
//            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
//            returndatacopy(0, 0, returndatasize())
//            switch result
//            case 0 {
//                revert(0, returndatasize())
//            }
//            default {
//                return (0, returndatasize())
//            }
//        }
//    }
//}
