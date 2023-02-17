// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Test} from "@forge-std/Test.sol";
import {RegisterScripts, console} from "@script/RegisterScripts.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {IERC1363WithSanction} from "@main/interfaces/IERC1363WithSanction.sol";

import {Errors} from "@main/shared/Error.sol";
import {SanctionRoles} from "@main/roles/SanctionRoles.sol";

contract TestERC1363WithSanctionRoles is Test, RegisterScripts {

    event SanctionAdminSetStarted(address indexed previousSanctionAdmin, address indexed newSanctionAdmin);
    event SanctionAdminSet(address indexed previousSanctionAdmin, address indexed newSanctionAdmin);

    address deployer;
    address alice = address(1);
    address bob = address(2);
    address carol = address(3);
    address dave = address(4);

    IERC1363WithSanction ERC1363WithSanction;

    function setUpScripts() internal override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public {

        deployer = msg.sender;
        vm.label(deployer, "Deployer");

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(address(this), "TestERC1363WithSanction");

        deal(alice, 1 ether);
        deal(bob, 1 ether);

        ERC1363WithSanction = IERC1363WithSanction(loadSavedDeployedAddress('ERC1363WithSanction'));
    }

    function test_setSanctionAdmin() public {
        vm.startPrank(deployer);

        vm.expectEmit(true,true,false,false);
        emit SanctionAdminSetStarted(deployer,bob);
        SanctionRoles(address(ERC1363WithSanction)).setSanctionAdmin(bob);
        
        assertEq(ERC1363WithSanction.sanctionAdmin(), deployer);
        assertEq(ERC1363WithSanction.pendingSanctionAdmin(), bob);

        vm.stopPrank();
        vm.startPrank(bob);

        vm.expectEmit(true,true,false,false);
        emit SanctionAdminSet(deployer,bob);
        SanctionRoles(address(ERC1363WithSanction)).acceptSanctionAdmin();
        assertEq(ERC1363WithSanction.sanctionAdmin(), bob);
        assertEq(ERC1363WithSanction.pendingSanctionAdmin(), address(0));

        vm.stopPrank();
    }



}