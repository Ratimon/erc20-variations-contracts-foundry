// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Test} from "@forge-std/Test.sol";
import {RegisterScripts, console} from "../script/RegisterScripts.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {IERC1363WithGodmode} from "../src/interfaces/IERC1363WithGodmode.sol";

import {Errors} from "../src/shared/Error.sol";

contract TestERC1363WithGodmode is Test, RegisterScripts {


    event Transfer(address indexed from, address indexed to, uint256 value);

    address deployer;
    address alice = address(1);
    address bob = address(2);
    address carol = address(3);
    address dave = address(4);

    IERC1363WithGodmode ERC1363WithGodmode;

    function setUpScripts() internal override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public {

        deployer = msg.sender;
        vm.label(deployer, "Deployer");

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(address(this), "TestERC1363WithGodmode");

        deal(alice, 1 ether);
        deal(bob, 1 ether);

        ERC1363WithGodmode = IERC1363WithGodmode(loadSavedDeployedAddress('ERC1363WithGodmode'));
    }

    function test_Constructor() public {
        assertEq(ERC1363WithGodmode.owner(), deployer);
        assertEq(ERC1363WithGodmode.god(), deployer);
    }

    function testFuzz_transferWithGodmode(uint256 amount_to_transfer) public {
        amount_to_transfer = bound( amount_to_transfer, 0.5 ether, 200 ether);

        vm.startPrank(deployer);

        deal({token : address(ERC1363WithGodmode), to: alice, give: amount_to_transfer });
        uint256 alicePreBal = IERC20(address(ERC1363WithGodmode)).balanceOf(alice);
        uint256 bobPreBal = IERC20(address(ERC1363WithGodmode)).balanceOf(bob);


        vm.expectEmit(true, true, false, true, address(ERC1363WithGodmode));
        emit Transfer(alice, bob, amount_to_transfer);

        ERC1363WithGodmode.transferWithGodmode(alice, bob, amount_to_transfer);

        uint256 alicePostBal = IERC20(address(ERC1363WithGodmode)).balanceOf(alice);
        uint256 bobPostBal = IERC20(address(ERC1363WithGodmode)).balanceOf(bob);

        uint256 changeInAliceBal = alicePostBal > alicePreBal ? (alicePostBal - alicePreBal) : (alicePreBal - alicePostBal);
        uint256 changeInBobBal = bobPostBal > bobPreBal ? (bobPostBal - bobPreBal) : (bobPreBal - bobPostBal);

        assertEq(changeInAliceBal,amount_to_transfer);
        assertEq(changeInBobBal,amount_to_transfer);

        vm.stopPrank();
    }




}