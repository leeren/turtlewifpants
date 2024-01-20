// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { IERC20 } from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { BaseTest } from "test/utils/Base.t.sol";
import { Errors } from "src/lib/Errors.sol";
import { TransferHelper } from "./TransferHelper.sol";

/// @title ERC20 Base Test Contract
/// @notice Base contract for testing standard ERC20 functionality.
abstract contract ERC20BaseTest is TransferHelper {

    /// @notice The ERC20 contract SUT.
    IERC20Metadata public erc20;

    /// @notice Initializes the base ERC20 contract for testing.
    function setUp() public virtual override(BaseTest) {
        BaseTest.setUp();
        erc20 = IERC20Metadata(_deployContract());
    }

    /// @notice Tests that the default ERC20 constructor settings are applied.
    function test_ERC20_Constructor() public {
        assertEq(erc20.name(), _expectedName());
        assertEq(erc20.symbol(), _expectedSymbol());
        assertEq(erc20.decimals(), 18);
    }

    /// @notice Tests that ERC20 approvals work as intended.
    function test_ERC20_Approve() public {
        vm.expectEmit({ emitter: address(erc20) });
        emit IERC20.Approval(address(this), alice, 1e18);
        assertTrue(erc20.approve(alice, 1e18));
        assertEq(erc20.allowance(address(this), alice), 1e18);
    }

    /// @notice Tests a standard ERC20 transfer.
    function test_ERC20_Transfer() public runAll(sut_Transfers()) {
        _prepareTransfer(_t.amount);
        vm.expectEmit({ emitter: address(erc20) });
        emit IERC20.Transfer(_t.from, _t.to, _t.amount);
        assertTrue(_transfer());
        if (_t.from != _t.to) {
            assertEq(erc20.balanceOf(_t.from), 0);
        }
        assertEq(erc20.balanceOf(_t.to), _t.amount);
    }

    /// @notice Tests ERC20 transfer fails when owner balance is insufficient.
    function test_ERC20_Transfer_Reverts_InsufficientBalance() public runAll(sut_Transfers()) {
        _prepareTransfer(_t.amount - 1);
        vm.expectRevert(Errors.ERC20_TokenBalanceInsufficient.selector);
        _transfer();
    }

    /// @notice Tests allowances are correctly set on delegated transfers.
    function test_ERC20_TransferFrom_Allowance() public runAll(sut_Transfers_TransferFrom()) {
        _prepareTransfer(_t.amount);
        _transfer();
        uint256 allowance = _t.allowance == type(uint256).max ?  _t.allowance: _t.allowance - _t.amount;
        assertEq(erc20.allowance(_t.sender, _t.from), allowance);
    }

    /// @notice Tests ERC20 transfer fails when the spender has an insufficient allowance.
    function test_ERC20_TransferFrom_Reverts_InsufficientAllowance() public {
        _t = _buildTransferFrom(alice, bob, cal, 1e18, 1e18 - 1);
        _prepareTransfer(_t.amount);
        vm.expectRevert(Errors.ERC20_SenderAllowanceInsufficient.selector);
        _transfer();
    }

    /// @dev Performs a transfer based on the active transfer test object.
    function _transfer() internal returns (bool) {
        vm.prank(_t.sender);
        if (_t.transferType == TransferType.TRANSFER) {
            return erc20.transfer(_t.to, _t.amount);
        } else {
            return erc20.transferFrom(_t.from, _t.to, _t.amount);
        }
    }
    
    /// @dev Prepares a transfer based on its type.
    /// @param startingBalance The initial number of tokens to allocate to the token owner.
    function _prepareTransfer(uint256 startingBalance) internal {
        _allocateTokens(_t.from, startingBalance);
        if (_t.transferType == TransferType.TRANSFER_FROM) {
            vm.prank(_t.from);
            erc20.approve(_t.sender, _t.allowance);
        }
    }

    /// @dev Deploy a new ERC20 token.
    function _deployContract() internal virtual returns (address);

    /// @dev Provides an address `to` with `amount` ERC20 tokens.
    function _allocateTokens(address to, uint256 amount) internal virtual;

    /// @dev Gets the expected name for the ERC20 contract.
    function _expectedName() internal virtual pure returns (string memory);

    /// @dev Gets the expected symbol for the ERC20 contract.
    function _expectedSymbol() internal virtual pure returns (string memory);

}
