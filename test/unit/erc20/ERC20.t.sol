// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { IERC20 } from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import { Errors } from "src/lib/Errors.sol";
import { MockERC20 } from "test/mocks/MockERC20.sol";
import { ERC20BaseTest } from "./ERC20Base.t.sol";

/// @title ERC20 Test Contract
/// @notice Tests standard ERC20 functionality.
contract ERC20Test is ERC20BaseTest {

    /// @notice The token contract SUT.
    MockERC20 public token;

    /// @notice Initializes the base token contract for testing.
    function setUp() public virtual override {
        ERC20BaseTest.setUp();
        token = MockERC20(address(erc20));
    }

    /// @notice Tests whether a mint successfully updates supply and balances.
    function test_ERC20_Mint() public {
        uint256 mintAmount = 1e18;
        vm.expectEmit({ emitter: address(erc20) });
        emit IERC20.Transfer(address(0), alice, mintAmount);
        token.mint(alice, mintAmount);
        assertEq(erc20.totalSupply(), mintAmount);
        assertEq(erc20.balanceOf(alice), mintAmount);
    }

    /// @notice Tests mint reverts on supply overflow.
    function test_ERC20_Mint_Reverts_SupplyOverflow() public {
        token.mint(alice, type(uint256).max);
        vm.expectRevert();
        token.mint(bob, 1);
    }

    /// @notice Tests whether a burn successfully updates supply and balances.
    function test_ERC20_Burn() public {
        uint256 mintAmount = 1e18;
        uint256 burnAmount = 1e16;
        token.mint(alice, mintAmount);
        vm.expectEmit({ emitter: address(erc20) });
        emit IERC20.Transfer(alice, address(0), burnAmount);
        token.burn(alice, burnAmount);
        assertEq(erc20.totalSupply(), mintAmount - burnAmount);
        assertEq(erc20.balanceOf(alice), mintAmount - burnAmount);
    }

    /// @notice Tests burn reverts when token balance is not sufficient.
    function test_ERC20_Burn_Reverts_InsufficientBalance() public {
        vm.expectRevert(Errors.ERC20_TokenBalanceInsufficient.selector);
        token.burn(alice, 1);
    }

    /// @dev Deploy a new ERC20 token.
    function _deployContract() internal override returns (address) {
        return address(new MockERC20());
    }

    /// @dev Provides an address `to` with `amount` ERC20 tokens.
    function _allocateTokens(address to, uint256 amount) internal override {
        token.mint(to, amount);
    }

    /// @dev Gets the expected name for the ERC20 contract.
    function _expectedName() internal pure override returns (string memory) {
        return "MOCKERC20";
    }

    /// @dev Gets the expected symbol for the ERC20 contract.
    function _expectedSymbol() internal pure override returns (string memory) {
        return "MOCK";
    }

}
