// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {JediVault} from "../src/JediVault.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SithToken is ERC20 {
    constructor() ERC20("Sith Token", "SITH") {
        _mint(msg.sender, 1000 ether);
    }
}

contract JediVaultTest is Test {
    JediVault public vault;
    SithToken public asset;
    address public user = makeAddr("user");
    using SafeERC20 for SithToken;

    function setUp() public {
        asset = new SithToken();
        vault = new JediVault(address(asset));

        // Distribute some SITH tokens to the user
        asset.safeTransfer(user, 100 ether);
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
}