// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Main.sol";

contract MainTest is Test {
    Main public main;

    // address[] public testAddresses;
    // uint256[] public tokenValues;

    function setUp() public {
        vm.startPrank(address(1));
        main = new Main();
        vm.stopPrank();
    }

    function testCheckOwner() public {
        assertEq(main.owner(), address(1));
    }

    function testBalanceOfOwner() public {
        assertEq(main.balanceOf(address(1)), 100000000000000000000);
    }

    // function testBatchTransfer() public {
    //     vm.startPrank(address(1));
    //     // main.batchTransfer(testAddresses, tokenValues);
    //     // assertEq(main.balanceOf(address(2)),10);
    //     // assertEq(main.balanceOf(address(3)),20);
    //     // assertEq(main.balanceOf(address(4)),30);
    //     console.log("success transferred all 3");
    //     console.log(main.balanceOf(address(5)));
    //     console.log("address length", testAddresses.length);
    // }

    function testAddTeam() public {
        vm.startPrank(address(1));
        main.addTeamAddress(address(2));
        assert(main.getIsTeamMember(address(2)));
    }

    function testAddWlCustomer() public {
        vm.startPrank(address(1));
        main.addTeamAddress(address(2));
        vm.stopPrank();

        vm.startPrank(address(2));
        main.addCustomnerWallet(address(3));
        assert(main.getIsCustomerWL(address(3)));
    }

    function testCalculateReward() public {
        vm.startPrank(address(1));
        main.addTeamAddress(address(2));
        vm.stopPrank();

        vm.startPrank(address(2));
        main.addCustomnerWallet(address(3));
        main.setLoyaltyTokensEarned(address(3), 20);
        (,uint256 purchase, uint tempReward,,,,) = main.purchaseRecord(0);
        uint cal = ((purchase * 1000) / 10000);
        assertEq(cal,tempReward);
        // console.log(tempReward);
    }
    
}
