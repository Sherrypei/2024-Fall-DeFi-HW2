// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Test, console2} from "forge-std/Test.sol";

import {TransparentBaseTest} from "./TransparentBase.t.sol";

interface IProxy {
    function upgradeTo(address _implementation) external;
    function proxyOwner() external returns (address);
    function implementation() external returns (address);
}

interface IBadName {
    function count() external view returns (uint256);
    function clash550254402() external;
    function upgradeTo() external;
}

interface IGoodName {
    function count() external view returns (uint256);
    function increment() external;
    function decrement() external;
}

contract TransparentTest is TransparentBaseTest {
     function testExploit() external validation {
        // Default Value //
        uint256 count;
        vm.prank(user);
        count = IBadName(address(proxy)).count();
        assertEq(count, 0, "Initial count should be 0");

        // BadName Proxy //
        vm.startPrank(user);
        
        // Check 1: Increment count
        IBadName(address(proxy)).clash550254402();
        count = IBadName(address(proxy)).count();
        assertEq(count, 1, "Count should be 1 after clash550254402");

        // Check 2: Decrement count
        IBadName(address(proxy)).upgradeTo();
        count = IBadName(address(proxy)).count();
        assertEq(count, 0, "Count should be 0 after upgradeTo");

        // Check 3: Try to decrement again (this might cause underflow)
        try IBadName(address(proxy)).upgradeTo() {
            count = IBadName(address(proxy)).count();
            assertEq(count, 0, "Count should remain 0 after second upgradeTo");
        } catch Error(string memory reason) {
            assertEq(reason, "Underflow", "Expected underflow error");
        } catch {
            revert("Unexpected error in upgradeTo");
        }

        vm.stopPrank();

        // Upgrade Proxy //
        vm.startPrank(owner);
        address addr = IProxy(address(proxy)).proxyOwner();
        assertEq(addr, owner, "Proxy owner should be the owner address");

        // Check 4: Upgrade to GoodName
        IProxy(address(proxy)).upgradeTo(address(goodName));
        address impl = IProxy(address(proxy)).implementation();
        assertEq(impl, address(goodName), "Implementation should be GoodName after upgrade");
        vm.stopPrank();

        // Check 5: Verify count after upgrade
        count = IGoodName(address(proxy)).count();
        assertEq(count, 0, "Count should be 0 after upgrade to GoodName");

        // GoodName Proxy
        vm.prank(user);
        IGoodName(address(proxy)).increment();
        count = IGoodName(address(proxy)).count();
        assertEq(count, 1, "Count should be 1 after increment");

        vm.prank(user);
        IGoodName(address(proxy)).decrement();
        count = IGoodName(address(proxy)).count();
        assertEq(count, 0, "Count should be 0 after decrement");
    }

    function testFunctionClashingAvoidance() external {
        // Test that the 'upgradeTo' function in the implementation does not clash with the proxy's 'upgradeTo'
        vm.startPrank(user);
        IBadName(address(proxy)).clash550254402();
        uint256 count = IBadName(address(proxy)).count();
        assertEq(count, 1);

        IBadName(address(proxy)).upgradeTo(); // This should call the implementation's upgradeTo, not the proxy's
        count = IBadName(address(proxy)).count();
        assertEq(count, 0); // Count should be decremented to 0
        vm.stopPrank();

        // Now test the proxy's upgradeTo function
        vm.prank(owner);
        address initialImplementation = IProxy(address(proxy)).implementation();
        IProxy(address(proxy)).upgradeTo(address(goodName));
        address newImplementation = IProxy(address(proxy)).implementation();
        assertEq(newImplementation, address(goodName));
        assertTrue(initialImplementation != newImplementation);
    }

    function testProxyAdminFunctions() external {
        // Test that admin functions are only callable by the admin
        vm.prank(owner);
        address currentImplementation = IProxy(address(proxy)).implementation();
        assertEq(currentImplementation, address(badName));

        vm.prank(owner);
        IProxy(address(proxy)).upgradeTo(address(goodName));

        vm.prank(owner);
        address newImplementation = IProxy(address(proxy)).implementation();
        assertEq(newImplementation, address(goodName));

        // Test that non-admin cannot call admin functions
        vm.startPrank(user);
        vm.expectRevert();
        IProxy(address(proxy)).upgradeTo(address(badName));

        vm.expectRevert();
        IProxy(address(proxy)).proxyOwner();

        vm.expectRevert();
        IProxy(address(proxy)).implementation();
        vm.stopPrank();
    }
}
