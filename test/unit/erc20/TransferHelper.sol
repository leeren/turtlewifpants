// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { BaseTest } from "test/utils/Base.t.sol";

/// @title Transer Helper Contract
/// @notice Utility contract for creating ERC20 transfer test simulations.
contract TransferHelper is BaseTest {

    // Used for identifying transfer types for test reuse.
    enum TransferType { TRANSFER, TRANSFER_FROM }

    // Encapsulates all details of an ERC20 transfer.
    struct Transfer {
        TransferType transferType; // Type of the transfer
        address sender;            // msg.sender
        address from;              // Original token owner
        address to;                // Token recipient
        uint256 amount;            // Number of tokens to send
        uint256 allowance;         // Number of tokens to approve for sender
    }

    // Internal helper 
    Transfer internal _t;      // The current transfer being examined.
    Transfer[] internal _ts;   // The current list of transfers being examined.

    /// @notice Modifier for running multiple transfer simulations for a test.
    modifier runAll(Transfer[] memory transfers) {
        for (uint256 i = 0; i < transfers.length; i++) {
            uint256 snapshot = vm.snapshot();
            _t = transfers[i];
            _;
            vm.revertTo(snapshot);
        }
    }

    /// @notice Creates a mixed set of ERC20 transfers.
    function sut_Transfers() internal returns (Transfer[] memory) {
        delete _ts;
        _ts.push(_buildTransfer(alice, bob, 1e18));
        _ts.push(_buildTransferFrom(alice, alice, bob, 1e18, type(uint256).max));
        _ts.push(_buildTransfer(alice, alice, 1e18));
        _ts.push(_buildTransferFrom(alice, alice, alice, 1e18, 1e19));
        return _ts;
    }

    /// @notice Creates a set of ERC20 `transferFrom` transfers.
    function sut_Transfers_TransferFrom() internal returns (Transfer[] memory) {
        delete _ts;
        _ts.push(_buildTransferFrom(alice, alice, bob, 1e18, type(uint256).max));
        _ts.push(_buildTransferFrom(alice, alice, alice, 1e18, 1e19));
        return _ts;
    }

    /// @dev Returns a built Transfer struct for a `transfer` call.
    function _buildTransfer(address sender, address to, uint256 amount) internal pure returns (Transfer memory) {
        return Transfer({
            transferType: TransferType.TRANSFER,
            sender: sender,
            from: sender,
            to: to,
            amount: amount,
            allowance: 0
        });
    }

    /// @dev Returns a built Transfer struct for a `transferFrom` call.
    function _buildTransferFrom(
        address sender,
        address from,
        address to,
        uint256 amount,
        uint256 allowance
    ) internal pure returns (Transfer memory) {
        return Transfer({
            transferType: TransferType.TRANSFER_FROM,
            sender: sender,
            from: from,
            to: to,
            amount: amount,
            allowance: allowance
        });
    }

}
