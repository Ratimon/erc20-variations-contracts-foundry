// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ISanctionRoles} from "@main/interfaces/ISanctionRoles.sol";

import {Errors} from "@main/shared/Error.sol";

import {MockSanctionRoles} from "@main/mocks/MockSanctionRoles.sol";
import {ConstantsFixture}  from "@test/unit/utils/ConstantsFixture.sol";

contract TestUnitSanctionRoles is ConstantsFixture {

    event SanctionAdminSetStarted(address indexed previousSanctionAdmin, address indexed newSanctionAdmin);
    event SanctionAdminSet(address indexed previousSanctionAdmin, address indexed newSanctionAdmin);

    struct Constructors_sanctionRoles {
        address initialOwner;
        address initialSanctionAdmin;
        address initialMinter;
    }
    Constructors_sanctionRoles arg_sanctionRoles;

    MockSanctionRoles sanctionRolesContract;

    function setUpScripts() internal override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public  virtual override {
        super.setUp();
        vm.label(address(this), "TestUnitERC1363WithSanctionRoles");

        vm.startPrank(deployer);

        arg_sanctionRoles.initialOwner = msg.sender;
        arg_sanctionRoles.initialSanctionAdmin = msg.sender;
        arg_sanctionRoles.initialMinter = msg.sender;

        sanctionRolesContract = new MockSanctionRoles(arg_sanctionRoles.initialOwner, arg_sanctionRoles.initialSanctionAdmin,  arg_sanctionRoles.initialMinter);
        vm.label(address(sanctionRolesContract), "sanctionRolesContract");

        vm.stopPrank();
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
