// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { LiquidityBaseTest } from "./LiquidityBase.t.sol";
import { IDEXFactory } from "src/interfaces/IDEXFactory.sol";
import { IDEXPair } from "src/interfaces/IDEXPair.sol";
import { IJoeRouter } from "src/interfaces/avax/IJoeRouter.sol";

/// @notice Tests for E2E LP provisioning using the Joe V1 Router.
contract AVAXLiquidityTest is LiquidityBaseTest {

    function setUp() public override {
        vm.createSelectFork({ urlOrAlias: "avax" });
        super.setUp();
    }

    // Adds liquidity using the assigned router of the forked chain.
    function _addLiquidity() internal override returns (uint256 lpTokens) {
        uint256 amount = _lpAmount();
        (,, lpTokens) = IJoeRouter(router).addLiquidityAVAX{value: amount}(
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
        return "AVAX_JOE_ROUTER_V1";
    }

    /// @dev Gets the expected environment variable for the DEX factory address.
    function _factory() internal override pure returns (string memory) {
        return "AVAX_JOE_FACTORY_V1";
    }

    /// @dev Gets the expected environment variable for the native wrapped token.
    function _wrappedNativeToken() internal override pure returns (string memory) {
        return "AVAX_WAVAX";
    }

    /// @dev Returns the amount to LP for testing.
    function _lpAmount() internal override pure returns (uint256) {
        return 50 ether;
    }

}
