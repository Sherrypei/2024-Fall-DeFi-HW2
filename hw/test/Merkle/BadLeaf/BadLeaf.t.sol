// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {BadLeafBaseTest} from "./BadLeafBase.t.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


contract BadLeafTest is BadLeafBaseTest, IERC721Receiver {

    function testExploit() external validation {
        vm.prank(owner);
        token.addPrivateSale(address(this), 2);
        vm.prank(owner);
        token.mint(address(this));
        vm.prank(owner);
        token.mint(address(this)); 
    }

    // 實現 IERC721Receiver 介面
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}