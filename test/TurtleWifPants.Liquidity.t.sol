// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/console2.sol";

import { TestHelper } from "joe-v2-test/helpers/TestHelper.sol";
import { AvalancheAddresses } from "joe-v2-test/integration/Addresses.sol";

/// @notice Tests for LP provisioning using the Joe V1 Router.
contract TurtleWifPantsLiquidityTest is TestHelper {

    function setUp() public override {
        super.setUp();
    }
    
    function test_FactoryAddress() public {
        assertEq(address(routerV1), AvalancheAddresses.JOE_V1_ROUTER, "test_FactoryAddress");
    }


}
