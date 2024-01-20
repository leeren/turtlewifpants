// SPDX-License-Identifier: MIT
//   
//   
//                                  ___-------___
//                              _-~~             ~~-_
//                           _-~                    /~-_
//        /^\__/^\         /   \                   /    \
//      /|  O|| O|        /      \_______________/        \
//     | |___||__|      /       /                \          \
//     |          \    /      /                    \          \
//     |   (_______) /______/                        \_________ \
//     |         / /         \                      /            \
//      \         \^\\         \                  /               \     /)
//        \         ||           \______________/      _-_       //\__//
//          \       ||/~********~_ ------------- \ --/~***~\    || __/
//            ~-----||~~~/****** |==================|*******|/~~~~~
//             (_(__/  ./     /                    \_\      \.
//                    (_(___/                         \_____)_)
//   
//                               twortle, wif pans
//
pragma solidity ^0.8.23;

import { ERC20 } from "src/ERC20.sol";
import { Errors } from "src/lib/Errors.sol";
import { Unownable } from "src/Unownable.sol";

/// @title Turtle Wif Pants Contract
contract TurtleWifPants is ERC20, Unownable {

    /// @notice Initializes the TURTLEWIFPANTS contract.
    constructor() ERC20("TURTLEWIFPANTS", "TURTL") {
        _mint(msg.sender, 69_420_000_000_000 * 1e18); // 69.420T token supply
    }

    /// @notice Returns whether the 1% transfer limit is being enforced.
    bool public onePercentLimitEnforced = true;

    /// @notice Returns the address of the $TURTL LP (or zero if not assigned).
    address public lp;

    /// @notice Sets whether or not the one percent transfer limit is enforced.
    /// @param enforced Whether or not to enforce the 1% transfer limit.
    function setOnePercentLimitEnforced(bool enforced) external onlyOwner {
        onePercentLimitEnforced = enforced;
    }

    /// @notice Enable trading by setting the LP address pair.
    /// @param liquidityPool Address of the $TURTL LP contract.
    function setLP(address liquidityPool) external onlyOwner {
        lp = liquidityPool;
    }

    /// @notice Burns `amount` tokens owned by the message sender.
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    /// @dev Validates whether a transfer is valid or not.
    /// @param to The recipient address of the token transfer.
    function _validateTransfer(address, address to, uint256) internal view override {
        if (onePercentLimitEnforced && to != lp && balanceOf[to] > totalSupply / 100) {
            revert Errors.TurtleWifPants_OnePercentTransferLimitExceeded();
        }
    }

}
