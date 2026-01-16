// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {JediVault, JediToken} from "../src/JediVault.sol";


contract JediVaultTest is Test {
    JediVault public vault;
    JediToken public asset;
    address public user = makeAddr("user");

    function setUp() public {
        asset = new JediToken(1000 ether);
        vault = new JediVault(address(asset));

        // Distribute some SITH tokens to the user
        require(asset.transfer(user, 100 ether), "Transfer failed");
    }

    function testDeposit() public {
        uint256 amount = 50 ether;

        vm.startPrank(user);
        asset.approve(address(vault), amount);
        vault.deposit(amount);
        vm.stopPrank();

        assertEq(vault.balanceOf(user), amount);
        assertEq(asset.balanceOf(address(vault)), amount);
    }

    function testWithdraw() public {
        uint256 amount = 50 ether;

        vm.startPrank(user);
        asset.approve(address(vault), amount);
        vault.deposit(amount);
        vault.withdraw(amount);
        vm.stopPrank();

        assertEq(vault.balanceOf(user), 0 ether);
        assertEq(asset.balanceOf(user), 100 ether);
    }

    function testDepositMultipleUsers() public {
        address user2 = makeAddr("user2");
        require(asset.transfer(user2, 100 ether), "Transfer failed");

        uint256 amount1 = 30 ether;
        uint256 amount2 = 70 ether;

        vm.startPrank(user);
        asset.approve(address(vault), amount1);
        vault.deposit(amount1);
        vm.stopPrank();

        vm.startPrank(user2);
        asset.approve(address(vault), amount2);
        vault.deposit(amount2);
        vm.stopPrank();

        assertEq(vault.balanceOf(user), amount1);
        assertEq(vault.balanceOf(user2), amount2);
        assertEq(asset.balanceOf(address(vault)), amount1 + amount2);
    }

    function testReverWhen_WithdrawExceedsBalance() public {
        uint256 depositAmount = 50 ether;
        uint256 withdrawAmount = 60 ether;

        vm.startPrank(user);
        asset.approve(address(vault), depositAmount);
        vault.deposit(depositAmount);

        vm.expectRevert("Burn amount exceeds balance");
        vault.withdraw(withdrawAmount);
        vm.stopPrank();
    }

    function testRevertWhen_DepositZeroAmount() public {
        vm.startPrank(user);
        asset.approve(address(vault), 0);

        vm.expectRevert("Amount must be greater than zero");
        vault.deposit(0);
        vm.stopPrank();
    }
}