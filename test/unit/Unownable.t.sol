// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { BaseTest } from "test/utils/Base.t.sol";
import { IUnownable } from "src/interfaces/IUnownable.sol";
import { Unownable } from "src/Unownable.sol";
import { Errors } from "src/lib/Errors.sol";

/// @title Unownable Test Contract
/// @notice Contract for testing ownership revocation in the unownable contract.
contract UnownableTest is BaseTest {

    /// @notice The Unownable contract SUT.
    IUnownable public unownable;

    /// @notice Initializes the base unownable contract for testing.
    function setUp() public virtual override {
        BaseTest.setUp();
        unownable = IUnownable(_deployContract());
    }

    /// @notice Tests that the default ERC20 constructor settings are applied.
    function test_Unownable_Constructor() public {
        vm.expectEmit();
        emit IUnownable.OwnershipTransferred(address(0), address(this));
        unownable = IUnownable(_deployContract());
        assertEq(unownable.owner(), address(this));
    }

    /// @dev Deploy a new Unownable contract.
    function test_Unownable_RevokeOwnership() public {
        assertEq(unownable.owner(), address(this));
        vm.expectEmit({ emitter: address(unownable) });
        emit IUnownable.OwnershipTransferred(address(this), address(0));
        unownable.revokeOwnership();
        assertEq(unownable.owner(), address(0));
    }

    /// @dev Tests that ownership revocation throws when not called by the owner.
    function test_Unownable_RevokeOwnership_Reverts_InvalidOwner() public {
        vm.expectRevert(Errors.OwnerInvalid.selector);
        vm.prank(alice);
        unownable.revokeOwnership();
    }

    /// @dev Deploy a new Unownable contract.
    function _deployContract() internal virtual returns (address) {
        return address(new Unownable());
    }

}
