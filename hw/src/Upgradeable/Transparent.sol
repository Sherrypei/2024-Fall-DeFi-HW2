// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BadName {
    uint256 public count;

    function clash550254402() external {
        count += 1;
    }

    function upgradeTo() external {
        count -= 1;
    }

    receive() external payable {}

    fallback() external payable {}
}

contract GoodName {
    uint256 public count;

    function increment() external {
        count += 1;
    }

    function decrement() external {
        count -= 1;
    }

    receive() external payable {}

    fallback() external payable {}
}

contract Proxy {
    // -1 for unknown preimage
    // 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    // 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103
    bytes32 private constant ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    // Constructor //
    constructor(address _implementation) {
        _setImplementation(_implementation);
        _setAdmin(msg.sender);
    }

    // Modifier //
    modifier ifAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    // External & Public Function //
    function upgradeTo(address _implementation) external ifAdmin {
        _setImplementation(_implementation);
        emit Upgraded(_implementation);
    }

    function changeAdmin(address _admin) external ifAdmin {
        require(_admin != address(0), "New admin is zero address");
        address previousAdmin = _getAdmin();
        _setAdmin(_admin);
        emit AdminChanged(previousAdmin, _admin);
    }

    function proxyOwner() external ifAdmin returns (address) {
        return _getAdmin();
    }

    function implementation() external ifAdmin returns (address) {
        return _getImplementation();
    }

    // Events //
    event AdminChanged(address previousAdmin, address newAdmin);
    event Upgraded(address indexed implementation);

    // Internal & Private Function //
    function _getAdmin() private view returns (address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    function _setAdmin(address _admin) private {
        require(_admin != address(0), "Admin Zero Address");
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = _admin;
    }

    function _getImplementation() private view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address _implementation) private {
        require(_implementation.code.length > 0, "Implementation Not Contract");
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
    }

    function _delegate(address _implementation) internal virtual {
        assembly {
            // Load free memory pointer
            let ptr := mload(0x40)
            // Copy function signature and arguments from calldata into memory
            calldatacopy(ptr, 0, calldatasize())
            // Delegatecall to the implementation
            let result := delegatecall(gas(), _implementation, ptr, calldatasize(), 0, 0)
            // Copy the returned data
            returndatacopy(ptr, 0, returndatasize())
            // Check if the call was successful
            switch result
            case 0 { revert(ptr, returndatasize()) }
            default { return(ptr, returndatasize()) }
        }
    }

    function _beforeFallback() internal virtual {
        require(msg.sender != _getAdmin(), "Admin cannot call implementation functions");
    }

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_getImplementation());
    }

    // Fallback & Receive Function //
    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }
}

// External Library //
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}