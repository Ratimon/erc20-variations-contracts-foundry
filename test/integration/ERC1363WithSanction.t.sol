// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IERC1363WithSanction} from "@main/interfaces/IERC1363WithSanction.sol";
import {Errors} from "@main/shared/Error.sol";

import {TestUnitERC1363WithSanction} from "@test/unit/ERC1363WithSanction.t.sol";

/**
 * @notice run `make void-deploy-sanction` before run testing command
 */
contract TestDeployScriptERC1363WithSanction is TestUnitERC1363WithSanction {

    function setUpScripts() internal virtual override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public virtual override {

        deployer = msg.sender;
        vm.label(deployer, "Deployer");

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(address(this), "TestERC1363WithSanction");

        deal(alice, 1 ether);
        deal(bob, 1 ether);
        erc1363WithSanction = IERC1363WithSanction(loadSavedDeployedAddress('ERC1363WithSanction'));
    }

}