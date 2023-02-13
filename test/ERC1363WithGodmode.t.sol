// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Test} from "@forge-std/Test.sol";
import {RegisterScripts, console} from "../script/RegisterScripts.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {IERC1363WithGodmode} from "../src/interfaces/IERC1363WithGodmode.sol";

import {Errors} from "../src/shared/Error.sol";

contract TestERC1363WithGodmode is Test, RegisterScripts {


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




}