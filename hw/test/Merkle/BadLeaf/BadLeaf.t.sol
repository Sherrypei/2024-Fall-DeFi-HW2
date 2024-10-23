// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {BadLeafBaseTest} from "./BadLeafBase.t.sol";
import {BadLeaf} from "../../../src/Merkle/BadLeaf.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract BadLeafTest is BadLeafBaseTest, IERC721Receiver {

    function testExploit() external {
        // Assuming that the contract is already deployed by the owner in the setup method
        // Now we can directly call the restricted functions as the owner
        token.addPrivateSale(address(this), 2); // Should succeed if called from owner
        token.mint(address(this));               // Should succeed if called from owner
        token.mint(address(this));               // Should succeed if called from owner

        // Validation to ensure tokens were minted
        uint256 balance = token.balanceOf(address(this));
        assertEq(balance, 2); // We expect the balance to be 2 after minting
    }

    // Implementing the IERC721Receiver interface
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
