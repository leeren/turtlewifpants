// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { ERC20 } from "src/ERC20.sol";
import { Errors } from "src/lib/Errors.sol";

/// @title Mock ERC20 Token Contract
contract MockERC20 is ERC20 {

    /// @notice Creates a mock ERC20 token contract.
    constructor() ERC20("MOCKERC20", "MOCK") {}

    /// @notice Mints `amount` tokens to address `to`.
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    /// @notice Burns `amount` tokens owned by address `from`.
    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }

}
