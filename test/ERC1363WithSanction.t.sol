// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Test} from "@forge-std/Test.sol";

import {RegisterScripts, console} from "../script/RegisterScripts.sol";

import {Errors} from "../src/shared/Error.sol";
import {ERC1363WithSanction} from "../src/ERC1363WithSanction.sol";


contract TestERC1363WithSanction is Test, RegisterScripts {

    address alice = address(1);
    address bob = address(2);
    address carol = address(3);
    address dave = address(4);

    ERC1363WithSanction tokenWithSanction;

    function setUpScripts() internal override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public {
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(address(this), "TestERC1363WithSanction");

        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);

        // string[] memory inputs = new string[](2);
        // inputs[0] = "make";
        // inputs[1] = "anvil-node";
        // bytes memory res = vm.ffi(inputs);

        // inputs = new string[](2);
        // inputs[0] = "make";
        // inputs[1] = "void-deploy";


        tokenWithSanction = ERC1363WithSanction(loadSavedDeployedAddress('ERC1363WithSanction'));
    }


    function unitTest_Deployment() internal view  {
    }

    function integrationTest_Deployment() internal view {
    }

    function test_RevertWhen_No() public {
        vm.startPrank(alice);

        vm.expectRevert(
            abi.encodeWithSelector(Errors.NotAuthorized.selector, alice)
        );
        tokenWithSanction.addToBlackList(bob);

        vm.stopPrank();
    }


}