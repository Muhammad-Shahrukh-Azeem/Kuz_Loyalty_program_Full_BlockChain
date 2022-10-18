// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {Main} from  "../src/Main.sol";


contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        new Main();
        vm.stopBroadcast();
    }
}
