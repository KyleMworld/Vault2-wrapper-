// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract JediVault is ERC20 {
    using SafeERC20 for IERC20;
    IERC20 public immutable ASSET;

    constructor(address _assetAddress) ERC20("Jedi Token", "JEDI") {
        ASSET = IERC20(_assetAddress);
    }

    function deposit(uint256 amount) external {
        ASSET.safeTransferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
        ASSET.safeTransfer(msg.sender, amount);
    }

}