// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import { BaseTest } from "test/utils/Base.t.sol";
import { IDEXFactory } from "src/interfaces/IDEXFactory.sol";
import { IDEXPair } from "src/interfaces/IDEXPair.sol";
import { TurtleWifPants } from "src/TurtleWifPants.sol";

/// @notice Tests for E2E LP provisioning using the DEX V1 Router.
abstract contract LiquidityBaseTest is BaseTest {

    address BURN = 0x000000000000000000000000000000000000dEaD;
    uint256 EXPECTED_SUPPLY = 69_420_000_000_000 * 1e18;

    address wrappedNativeToken;
    uint256 amountToLP;
    TurtleWifPants token;
    IDEXFactory factory;
    IDEXPair pair;
    address router;

    function setUp() public virtual override {
        super.setUp();
        factory = IDEXFactory(vm.envAddress(_factory()));
        wrappedNativeToken = vm.envAddress(_wrappedNativeToken());
        router = vm.envAddress(_router());
        token = new TurtleWifPants();
        deal(address(this), 99 ether);
    }

    function test_TurtleWifPants_Liquidity_SetupLP() public {
        assertEq(token.balanceOf(address(this)), EXPECTED_SUPPLY);
        pair = IDEXPair(factory.createPair(address(token), wrappedNativeToken));
        token.setLP(address(pair));
        token.approve(address(router), type(uint256).max);
        uint256 lpTokens = _addLiquidity();
        pair.transfer(BURN, lpTokens);
        token.setOnePercentLimitEnforced(false);
        token.revokeOwnership();
    }

    // Adds liquidity using the assigned router of the forked chain.
    function _addLiquidity() internal virtual returns (uint256);

    /// @dev Gets the expected environment variable for the DEX router address.
    function _router() internal virtual pure returns (string memory);

    /// @dev Gets the expected environment variable for the DEX factory address.
    function _factory() internal virtual pure returns (string memory);

    /// @dev Gets the expected environment variable for the native wrapped token.
    function _wrappedNativeToken() internal virtual pure returns (string memory);

    /// @dev Returns the amount of native token to LP.
    function _lpAmount() internal virtual pure returns (uint256);

}
