// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { LiquidityBaseTest } from "./LiquidityBase.t.sol";
import { IDEXFactory } from "src/interfaces/IDEXFactory.sol";
import { IDEXPair } from "src/interfaces/IDEXPair.sol";
import { IUniswapRouter } from "src/interfaces/eth/IUniswapRouter.sol";

/// @notice Tests for E2E LP provisioning using the Uniswap V2 Router.
contract ETHLiquidityTest is LiquidityBaseTest {

    function setUp() public override {
        vm.createSelectFork({ urlOrAlias: "eth" });
        super.setUp();
    }

    // Adds liquidity using the assigned router of the forked chain.
    function _addLiquidity() internal override returns (uint256 lpTokens) {
        uint256 amount = _lpAmount();
        (,, lpTokens) = IUniswapRouter(router).addLiquidityETH{value: amount}(
            address(token),
            EXPECTED_SUPPLY,
            EXPECTED_SUPPLY,
            amount,
            address(this),
            block.timestamp + 20 minutes
        );
    }

    /// @dev Gets the expected environment variable for the DEX router address.
    function _router() internal override  pure returns (string memory) {
        return "ETH_UNISWAP_ROUTER_V2";
    }

    /// @dev Gets the expected environment variable for the DEX factory address.
    function _factory() internal override pure returns (string memory) {
        return "ETH_UNISWAP_FACTORY_V2";
    }

    /// @dev Gets the expected environment variable for the native wrapped token.
    function _wrappedNativeToken() internal override pure returns (string memory) {
        return "ETH_WETH";
    }

    /// @dev Returns the amount to LP for testing.
    function _lpAmount() internal override pure returns (uint256) {
        return 1 ether;
    }

}
