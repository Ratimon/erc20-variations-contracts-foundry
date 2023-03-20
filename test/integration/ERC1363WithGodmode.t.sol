// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";
import {RegisterScripts, console} from "@script/RegisterScripts.sol";

import {IERC1363WithGodmode} from "@main/interfaces/IERC1363WithGodmode.sol";
import {Errors} from "@main/shared/Error.sol";

import {TestUnitERC1363WithGodmode} from "@test/unit/ERC1363WithGodmode.t.sol";

/**
 * @notice run `make fork-node` then `make void-deploy-god` before run testing command
 */
contract TestDeployScriptERC1363WithGodmode is TestUnitERC1363WithGodmode {

    function setUpScripts() internal virtual override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public virtual override {
        vm.label(address(this), "TestDeployScriptERC1363WithGodmode");

        deployer = msg.sender;
        vm.label(deployer, "Deployer");

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");

        deal(alice, 1 ether);
        deal(bob, 1 ether);

        erc1363WithGodmode = IERC1363WithGodmode(loadSavedDeployedAddress('ERC1363WithGodmode'));
    }

}