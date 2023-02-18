// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;
import {Test} from "@forge-std/Test.sol";
import {RegisterScripts, console} from "@script/RegisterScripts.sol";

import {ISanctionRoles} from "@main/interfaces/ISanctionRoles.sol";

import {Errors} from "@main/shared/Error.sol";
import {MockSanctionRoles} from "@main/mocks/MockSanctionRoles.sol";

contract TestUnitERC1363WithSanctionRoles is Test, RegisterScripts {

    event SanctionAdminSetStarted(address indexed previousSanctionAdmin, address indexed newSanctionAdmin);
    event SanctionAdminSet(address indexed previousSanctionAdmin, address indexed newSanctionAdmin);

    address deployer;
    address alice = address(1);
    address bob = address(2);
    address carol = address(3);
    address dave = address(4);

    struct Constructors {
        address initialOwner;
        address initialSanctionAdmin;
        address initialMinter;
    }
    Constructors arguments;

    MockSanctionRoles sanctionRolesContract;

    function setUpScripts() internal override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public {
        vm.label(address(this), "TestUnitERC1363WithSanctionRoles");

        deployer = msg.sender;
        vm.label(deployer, "Deployer");

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        

        deal(alice, 1 ether);
        deal(bob, 1 ether);

        arguments.initialOwner = msg.sender;
        arguments.initialSanctionAdmin = msg.sender;
        arguments.initialMinter = msg.sender;

        sanctionRolesContract = new MockSanctionRoles(arguments.initialOwner, arguments.initialSanctionAdmin,  arguments.initialMinter);
    }

    function test_setSanctionAdmin() public {
        vm.startPrank(deployer);

        vm.expectEmit(true,true,false,false);
        emit SanctionAdminSetStarted(deployer,bob);
        ISanctionRoles(address(sanctionRolesContract)).setSanctionAdmin(bob);
        
        assertEq(ISanctionRoles(address(sanctionRolesContract)).sanctionAdmin(), deployer);
        assertEq(ISanctionRoles(address(sanctionRolesContract)).pendingSanctionAdmin(), bob);

        vm.stopPrank();
        vm.startPrank(bob);

        vm.expectEmit(true,true,false,false);
        emit SanctionAdminSet(deployer,bob);
        ISanctionRoles(address(sanctionRolesContract)).acceptSanctionAdmin();
        assertEq(ISanctionRoles(address(sanctionRolesContract)).sanctionAdmin(), bob);
        assertEq(ISanctionRoles(address(sanctionRolesContract)).pendingSanctionAdmin(), address(0));

        vm.stopPrank();
    }



}
