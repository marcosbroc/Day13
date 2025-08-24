// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * Using openzeppelin functionality to control owner access, contract pausing and reentrancy
 */
contract Vault is Ownable, ReentrancyGuard, Pausable {
    mapping(address => uint256) public balances;

    constructor() Ownable(msg.sender) {}

    /**
     * Deposit is only available if the contract is not paused.
     */
    function deposit() external payable whenNotPaused {
        require(msg.value > 0, "No ETH to deposit");
        balances[msg.sender] += msg.value;
    }

    /**
     * Withdraw is only available if the contract is not paused.
     * Using a modifier to prevent reentrancy attacks.
     * The balance must be updated BEFORE sending the ether.
     */
    function withdraw(uint256 amount) external nonReentrant whenNotPaused {
        require(amount <= balances[msg.sender], "Not enough balance");
        balances[msg.sender] -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "ETH withdrawal failed");
    }

    /**
     * Simply calling the inherited pause function
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * Simply calling the inherited unpause function
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}
