// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Test} from "@forge-std/Test.sol";
import {RegisterScripts, console} from "../script/RegisterScripts.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {IERC1363WithSanction} from "@main/interfaces/IERC1363WithSanction.sol";

import {Errors} from "@main/shared/Error.sol";

contract TestERC1363WithSanction is Test, RegisterScripts {

    event BlackListAdded(address indexed blacklist);
    event BlackListRemoved(address indexed blacklist);

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

    function test_Constructor() public {
        assertEq(ERC1363WithSanction.owner(), deployer);
        assertEq(ERC1363WithSanction.sanctionAdmin(), deployer);
    }

    function test_RevertWhen_NotAuthorized_addToBlackList() public {
        vm.startPrank(alice);

        vm.expectRevert(
            abi.encodeWithSelector(Errors.NotAuthorized.selector, alice)
        );
        ERC1363WithSanction.addToBlackList(bob);

        vm.stopPrank();
    }

    function test_addToBlackList() public {
        vm.startPrank(deployer);

        vm.expectEmit(true,false,false,false);
        emit BlackListAdded(bob);
        ERC1363WithSanction.addToBlackList(bob);
        assertEq(ERC1363WithSanction.isBlacklist(bob), true);

        vm.stopPrank();
        vm.startPrank(bob);

        deal({token : address(ERC1363WithSanction), to: bob, give: 10 ether });
        uint256 balance = IERC20(address(ERC1363WithSanction)).balanceOf(bob);
        assertEq(balance, 10 ether);
        
        vm.expectRevert(
            bytes("The caller is on the blacklist")
        );
        IERC1363(address(ERC1363WithSanction)).transferAndCall(carol, 2 ether);

        vm.stopPrank();
    }

    function testFuzz_addToBlackList(uint256 amount_to_send) public {
        amount_to_send = bound( amount_to_send, 0.5 ether, 10 ether);

        vm.startPrank(deployer);

        vm.expectEmit(true,false,false,false);
        emit BlackListAdded(bob);
        ERC1363WithSanction.addToBlackList(bob);
        assertEq(ERC1363WithSanction.isBlacklist(bob), true);

        vm.stopPrank();
        vm.startPrank(bob);

        deal({token : address(ERC1363WithSanction), to: bob, give: amount_to_send });

        uint256 balance = IERC20(address(ERC1363WithSanction)).balanceOf(bob);
        assertEq(balance, amount_to_send);
        
        vm.expectRevert(
            bytes("The caller is on the blacklist")
        );
        IERC1363(address(ERC1363WithSanction)).transferAndCall(carol, amount_to_send);

        vm.stopPrank();
    }

    function testFuzz_removeFromBlackList(uint256 amount_to_send) public {
        amount_to_send = bound( amount_to_send, 0.5 ether, 10 ether);

        vm.startPrank(deployer);

        ERC1363WithSanction.addToBlackList(bob);
        assertEq(ERC1363WithSanction.isBlacklist(bob), true);

        ERC1363WithSanction.removeFromBlacklist(bob);
        assertEq(ERC1363WithSanction.isBlacklist(bob), false);

        vm.stopPrank();
    }


}