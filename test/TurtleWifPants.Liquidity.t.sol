// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/console2.sol";

import { TestHelper } from "joe-v2-test/TestHelper.sol";

/// @notice Tests for LP provisioning using the Joe V1 Router.
contract TurtleWifPantsLiquidityTest is TestHelper {

    function setUp() public {
    }
    
    function test_FactoryAddress() public {
        assertEq(address(routerV1), JOE_V1_ROUTER_ADDRESS, "test_FactoryAddress");
    }


}
