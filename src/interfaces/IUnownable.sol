// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/// @title Unownable Contract Interface
interface IUnownable {

    /// @notice Transfers contract ownership from `prevOwner` to `newOwner`.
    /// @param prevOwner The current owner of the contract.
    /// @param newOwner The new owner of the contract.
    event OwnershipTransferred(address prevOwner, address newOwner);

    /// @notice Gets the current owner of the contract.
    function owner() external returns (address);

    /// @notice Permanently revokes ownership of the underlying contract.
    function revokeOwnership() external;
}
