// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {IERC1363WithGodmode} from "@main/interfaces/IERC1363WithGodmode.sol";

import {Errors} from "@main/shared/Error.sol";
import {GodRoles} from "@main/roles/GodRoles.sol";
import {ERC1363WithGodmode} from "@main/ERC1363WithGodmode.sol";

import {ConstantsFixture}  from "@test/unit/utils/ConstantsFixture.sol";
import {DeploymentERC1363WithGodmode}  from "@test/unit/utils/ERC1363WithGodmode.constructor.sol";


contract TestUnitERC1363WithGodmode is  ConstantsFixture, DeploymentERC1363WithGodmode {

    event Transfer(address indexed from, address indexed to, uint256 value);

    IERC1363WithGodmode erc1363WithGodmode;

    function setUpScripts() internal virtual override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public  virtual override {
        super.setUp();
        vm.label(address(this), "TestUnitERC1363WithGodmode");
        
        vm.startPrank(deployer);

        arg_erc1363WithGodmode.name = "Test Sanction Token";
        arg_erc1363WithGodmode.symbol = "SANC";
        arg_erc1363WithGodmode.initialOwner = msg.sender;
        arg_erc1363WithGodmode.initialSanctionAdmin = msg.sender;

        erc1363WithGodmode = new ERC1363WithGodmode(
            arg_erc1363WithGodmode.name,
            arg_erc1363WithGodmode.symbol,
            arg_erc1363WithGodmode.initialOwner,
            arg_erc1363WithGodmode.initialSanctionAdmin
        );
        vm.label(address(erc1363WithGodmode), "erc1363WithGodmode");

        vm.stopPrank();
    }

    function test_Constructor() public {
        assertEq(GodRoles(address(erc1363WithGodmode)).owner(), deployer);
        assertEq(GodRoles(address(erc1363WithGodmode)).god(), deployer);
    }

    function test_RevertWhen_NotAuthorized_transferWithGodmode() public {
        uint256 amount_to_transfer = 1 ether;
        vm.startPrank(carol);

        deal({token : address(erc1363WithGodmode), to: alice, give: amount_to_transfer });
        vm.expectRevert(
            abi.encodeWithSelector(Errors.NotAuthorized.selector, carol)
        );
        erc1363WithGodmode.transferWithGodmode(alice, bob, amount_to_transfer);

        vm.stopPrank();
    }

    function testFuzz_transferWithGodmode(uint256 amount_to_transfer) public {
        amount_to_transfer = bound( amount_to_transfer, 0.5 ether, 200 ether);

        deal({token : address(erc1363WithGodmode), to: alice, give: amount_to_transfer });

        vm.startPrank(deployer);

        uint256 alicePreBal = IERC20(address(erc1363WithGodmode)).balanceOf(alice);
        uint256 bobPreBal = IERC20(address(erc1363WithGodmode)).balanceOf(bob);
        vm.expectEmit(true, true, false, true, address(erc1363WithGodmode));
        emit Transfer(alice, bob, amount_to_transfer);

        erc1363WithGodmode.transferWithGodmode(alice, bob, amount_to_transfer);

        uint256 alicePostBal = IERC20(address(erc1363WithGodmode)).balanceOf(alice);
        uint256 bobPostBal = IERC20(address(erc1363WithGodmode)).balanceOf(bob);

        uint256 changeInAliceBal = alicePostBal > alicePreBal ? (alicePostBal - alicePreBal) : (alicePreBal - alicePostBal);
        uint256 changeInBobBal = bobPostBal > bobPreBal ? (bobPostBal - bobPreBal) : (bobPreBal - bobPostBal);

        assertEq(changeInAliceBal,amount_to_transfer);
        assertEq(changeInBobBal,amount_to_transfer);

        vm.stopPrank();
    }
}