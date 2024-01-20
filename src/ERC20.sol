// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { IERC20Metadata } from "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { Errors } from "src/lib/Errors.sol";

/// @title ERC20 Token Contract
abstract contract ERC20 is IERC20Metadata {

    /// @notice Gets the token balance for an owner address.
    mapping(address owner => uint256) public balanceOf;

    /// @notice Gets the token allowance of a spender on behalf of an owner.
    mapping(address owner => mapping(address spender => uint256)) public allowance;

    /// @notice Gets the total supply of the token.
    uint256 public totalSupply;

    /// @notice Gets the name of the token.
    string public name;

    /// @notice Gets the symbol of the token.
    string public symbol;

    /// @notice Gets the number of token decimals, fixed to 18.
    uint8 public decimals = 18;

    /// @notice Creates a new ERC20 token.
    /// @param name_ The name to be used for the token.
    /// @param symbol_ The symbol to be used for the token.
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    /// @notice Approves a spender to spend tokens on behalf of the sender.
    /// @param spender The address of the spender being granted an allowance.
    /// @param amount The token amount being granted for the spender allowance.
    /// @return Whether or not the approval was successful.
    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /// @notice Transfers `amount` tokens from sender to recipient address `to`.
    /// @param to The address of the recipient receiving the tokens.
    /// @param amount The number of tokens being transferrd to the recipient.
    /// @return Whether the transfer was successful or not.
    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    /// @notice Transfers `amount` tokens from address `from` to address `to`.
    /// @param from The address of the owner whose tokens are being transferred.
    /// @param to The recipient address of the token transfer.
    /// @param amount The number of tokens being transferred.
    /// @return Whether the transfer was successful or not.
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        uint256 senderAllowance = allowance[from][msg.sender];
        if ((senderAllowance) != type(uint256).max) {
            if (senderAllowance < amount) {
                revert Errors.ERC20_SenderAllowanceInsufficient();
            }
            unchecked {
                allowance[from][msg.sender] = senderAllowance - amount;
            }
        }
        _transfer(from, to, amount);
        return true;
    }

    /// @dev Transfers tokens from address `from` to address `to`.
    /// @param from The address of the owner whose tokens are being transferred.
    /// @param to The recipient address of the token transfer.
    /// @param amount The number of tokens being transferred.
    function _transfer(address from, address to, uint256 amount) internal {
        uint256 balance = balanceOf[from];
        if (balance < amount) {
            revert Errors.ERC20_TokenBalanceInsufficient();
        }
        unchecked {
            balanceOf[from] -= amount;
            balanceOf[to] += amount;
        }
        _validateTransfer(from, to, amount);
        emit Transfer(from, to, amount);
    }

    /// @dev Validates whether a transfer is valid or not.
    /// @param from The address of the owner whose tokens are being transferred.
    /// @param to The recipient address of the token transfer.
    /// @param amount The number of tokens being transferred.
    function _validateTransfer(address from, address to, uint256 amount) internal virtual {}

    /// @dev Mints `amount` tokens to recipient address `to`.
    /// @param to The address receiving the minted tokens.
    /// @param amount The number of tokens to mint to address `to`.
    function _mint(address to, uint256 amount) internal {
        totalSupply += amount; // Only place overflow of supply must be checked.
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(address(0), to, amount);
    }

    /// @dev Burns `amount` tokens owned by address `from`.
    /// @param from The address whose tokens are being burned.
    /// @param amount The number of tokens to burn.
    function _burn(address from, uint256 amount) internal {
        uint256 balance = balanceOf[from];
        if (balance < amount) {
            revert Errors.ERC20_TokenBalanceInsufficient();
        }
        unchecked {
            balanceOf[from] -= amount;
            totalSupply -= amount;
        }
        emit Transfer(from, address(0), amount);
    }
}
