// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20 {
    constructor(uint256 _amount) ERC20("ZainabRewardToken", "ZRT") {
        _mint(msg.sender, _amount);  // Mint reward tokens to contract deployer
    }
}