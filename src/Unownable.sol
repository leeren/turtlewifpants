// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { Errors } from "src/lib/Errors.sol";
import { IUnownable } from "./interfaces/IUnownable.sol";

/// @title Unownable Contract
/// @notice Contract built for irreversible revocation of ownership.
contract Unownable is IUnownable {

    /// @notice The current contract owner address.
    address public owner;

    /// @notice Modifier to ensure message sender is the contract owner.
    modifier onlyOwner {
        if (msg.sender != owner) {
            revert Errors.OwnerInvalid();
        }
        _;
    }

    /// @notice Creates the contract, signifying owner transfer to sender.
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /// @notice Permanently revokes ownership of the underlying contract.
    function revokeOwnership() external onlyOwner {
        address oldOwner = owner;
        owner = address(0);
        emit OwnershipTransferred(oldOwner, address(0));
    }
}
