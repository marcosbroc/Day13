// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";

contract VaultScript is Script {
    Vault public vault;
    address[] public depositors;
    address public owner;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        vault = new Vault();
        owner = address(vault);
        vm.stopBroadcast();
    }
}
