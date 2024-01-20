// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { IERC20 } from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import { Errors } from "src/lib/Errors.sol";
import { UnownableTest } from "./Unownable.t.sol";
import { ERC20BaseTest } from "./erc20/ERC20Base.t.sol";
import { TurtleWifPants } from "src/TurtleWifPants.sol";

/// @notice Tests for Turtle Wif Pants ERC20 core token functionality.
contract TurtleWifPantsTest is ERC20BaseTest, UnownableTest {

    // Mock LP address.
    address internal lp = vm.addr(0x1337);

    /// @notice The token contract SUT.
    TurtleWifPants public token;

    /// @notice Expected initial supply for token $TURTL.
    uint256 public constant INITIAL_SUPPLY = 69_420_000_000_000 * 1e18;

    /// @notice Sets up the TurtleWifPants testing contract.
    function setUp() public override(ERC20BaseTest, UnownableTest) {
        UnownableTest.setUp();
        ERC20BaseTest.setUp();
        token = TurtleWifPants(address(erc20));
        token.setOnePercentLimitEnforced(false);
    }

    /// @notice Creates ERC20 transfers that transfer >1% of the expected supply.
    function sut_Transfers_ExceededLimit() internal returns (Transfer[] memory) {
        delete _ts;
        _ts.push(_buildTransfer(alice, bob, INITIAL_SUPPLY / 100 + 1));
        _ts.push(_buildTransferFrom(alice, alice, bob, INITIAL_SUPPLY / 100 + 1, type(uint256).max));
        return _ts;
    }

    /// @notice Tests that expected settings applied on token creation.
    function test_TurtleWifPants_Constructor() public {
        vm.expectEmit();
        emit IERC20.Transfer(address(0), address(this), INITIAL_SUPPLY);
        token = TurtleWifPants(_deployContract());
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(address(this)), INITIAL_SUPPLY);
        assertEq(token.lp(), address(0));
        assertTrue(token.onePercentLimitEnforced());
    }

    /// @notice Tests whether a burn successfully updates supply and balances.
    function test_TurtleWifPants_Burn() public {
        uint256 totalSupply = token.totalSupply();
        uint256 balance = token.balanceOf(address(this));
        uint256 burnAmount = 1e16;
        vm.expectEmit({ emitter: address(token) });
        emit IERC20.Transfer(address(this), address(0), burnAmount);
        token.burn(burnAmount);
        assertEq(token.totalSupply(), totalSupply - burnAmount);
        assertEq(token.balanceOf(address(this)), balance - burnAmount);
    }

    /// @notice Tests burn reverts when token balance is not sufficient.
    function test_TurtleWifPants_Burn_Reverts_InsufficientBalance() public {
        vm.expectRevert(Errors.ERC20_TokenBalanceInsufficient.selector);
        vm.prank(alice);
        token.burn(1);
    }

    /// @notice Tests transfers of >1% of supply fail when the limit is enforced.
    function test_TurtleWifHat_Transfer_Reverts_TransferLimitExceeded() public runAll(sut_Transfers_ExceededLimit()) {
        _prepareTransfer(_t.amount);
        token.setOnePercentLimitEnforced(true);
        vm.expectRevert(Errors.TurtleWifPants_OnePercentTransferLimitExceeded.selector);
        _transfer();
    }

    /// @notice Tests limit-restricted transfers succeed when recipient is the LP.
    function test_TurtleWifHat_Transfer_LPRecipient() public runAll(sut_Transfers_ExceededLimit()) {
        _prepareTransfer(_t.amount);
        token.setOnePercentLimitEnforced(true);
        token.setLP(_t.to);
        _transfer();
    }


    /// @notice Tests allowances are correctly set on delegated transfers.
    function test_TurtleWifPants_Transfer_Allowance() public runAll(sut_Transfers_TransferFrom()) {
        _prepareTransfer(_t.amount);
        _transfer();
        uint256 allowance = _t.allowance == type(uint256).max ?  _t.allowance: _t.allowance - _t.amount;
        assertEq(erc20.allowance(_t.sender, _t.from), allowance);
    }

    /// @dev Provides an address `to` with `amount` ERC20 tokens.
    function _allocateTokens(address to, uint256 amount) internal override(ERC20BaseTest) {
        token.transfer(to, amount);
    }

    /// @dev Gets the expected name for the ERC20 contract.
    function _expectedName() internal pure override(ERC20BaseTest) returns (string memory) {
        return "TURTLEWIFPANTS";
    }

    /// @dev Gets the expected symbol for the ERC20 contract.
    function _expectedSymbol() internal pure override(ERC20BaseTest) returns (string memory) {
        return "TURTL";
    }

    /// @dev Deploy a new TurtleWifPants contract.
    function _deployContract() internal override(ERC20BaseTest, UnownableTest) returns (address) {
        return address(new TurtleWifPants());
    }
    
}
