// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";

contract VaultTest is Test {
    Vault public vault;
    address[] public depositors;
    address public owner;

    function setUp() public {
        // Create the depositors and fund them
        depositors.push(vm.envAddress("ACCOUNT_1"));
        vm.deal(vm.envAddress("ACCOUNT_1"), 20 ether);
        depositors.push(vm.envAddress("ACCOUNT_2"));
        vm.deal(vm.envAddress("ACCOUNT_2"), 15 ether);
        depositors.push(vm.envAddress("ACCOUNT_3"));
        vm.deal(vm.envAddress("ACCOUNT_3"), 50 ether);

        // Initialise the vault (by owner)
        vault = new Vault();
        owner = address(this);
    }

    /**
     * Basic test that checks:
     * 1) Deposit is properly done.
     * 2) Withdraw is properly done.
     * 3) Only the owner can pause/unpause.
     * 4) No deposits or withdraws are allowed when the contract is paused.
     */
    function testBasic() public {
        // Individual A deposits 1 ETH
        vm.prank(depositors[0]);
        vault.deposit{value: 5 ether}();
        console.log("Depositor A is", depositors[0], "and has now ETH", depositors[0].balance / 1 ether);

        // Owner pauses the contract
        vm.prank(owner);
        vault.pause();

        // Individual B tries to deposit 1 ETH on the paused contract
        vm.prank(depositors[1]);
        vm.expectRevert();
        vault.deposit{value: 1 ether}();
        console.log("Depositor B is", depositors[1], "and has now ETH", depositors[1].balance / 1 ether);

        // Owner unpauses the contract
        vm.prank(owner);
        vault.unpause();

        // Individual B now tries to deposit 1 ETH on the resumed contract
        vm.prank(depositors[1]);
        vault.deposit{value: 1 ether}();
        console.log("Depositor B is", depositors[1], "and has now ETH", depositors[1].balance / 1 ether);

        // Individual A now tries to withdraw 4 ETH from the contract
        vm.prank(depositors[0]);
        vault.withdraw(4 ether);
        console.log("Depositor A is", depositors[0], "and has now ETH", depositors[0].balance / 1 ether);

        // Individual B now tries to withdraw 2 ETH (more than she deposited)
        vm.prank(depositors[1]);
        vm.expectRevert("Not enough balance");
        vault.withdraw(2 ether);
        console.log("Depositor B is", depositors[1], "and has now ETH", depositors[1].balance / 1 ether);

        // Individual C tries to pause the contract, but he is not the owner
        vm.prank(depositors[2]);
        vm.expectRevert();
        vault.pause();
    }
}
