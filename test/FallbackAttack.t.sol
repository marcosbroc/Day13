// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Vault.sol"; // Adjust path to your Vault contract

/**
 * A test to simulate an attacker trying to exploit the fact that,
 * when ETH is sent without data, the special receive() function is automatically called
 * on the receiving contract. Luckily, our contract has ReentrancyGuard
 * so the status of entry is kept and the whole call reverted.
 */
contract Attacker {
    Vault public vault;

    constructor(address _vault) {
        vault = Vault(_vault);
    }

    // This gets called when Vault sends ETH back to this contract
    receive() external payable {
        // Reenter the Vault while the previous withdraw hasn't finished
        if (address(vault).balance >= 0.1 ether) {
            vault.withdraw(0.1 ether);
        }
    }

    // Deposit and immediately withdraw to trigger receive()
    function attack() external payable {
        vault.deposit{value: msg.value}();
        vault.withdraw(msg.value);
    }
}

contract FallbackAttackTest is Test {
    Vault public vault;
    Attacker public attacker;

    function setUp() public {
        vault = new Vault();
        attacker = new Attacker(address(vault));

        // Give the Vault some initial funds (simulate other users depositing)
        vm.deal(address(vault), 5 ether);

        // Fund the attacker
        vm.deal(address(attacker), 1 ether);
    }

    function testFallbackAttack() public {
        // Start impersonating attacker
        vm.startPrank(address(attacker));

        // Vault reverts as it's protected with ReentrancyGuard.
        // Remove vm.expectRevert() to observe the exploit
        vm.expectRevert();

        attacker.attack{value: 1 ether}();

        vm.stopPrank();
    }
}
