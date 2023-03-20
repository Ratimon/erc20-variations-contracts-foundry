// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC1363WithSanction} from "@main/interfaces/IERC1363WithSanction.sol";
import {Errors} from "@main/shared/Error.sol";

import {TestUnitERC1363WithSanction} from "@test/unit/ERC1363WithSanction.t.sol";

/**
 * @notice run `make fork-node` then `make void-deploy-sanction` before run testing command
 */
contract TestDeployScriptERC1363WithSanction is TestUnitERC1363WithSanction {

    function setUpScripts() internal virtual override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public virtual override {
        vm.label(address(this), "TestDeployScriptERC1363WithSanction");

        deployer = msg.sender;
        vm.label(deployer, "Deployer");

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        

        deal(alice, 1 ether);
        deal(bob, 1 ether);
        erc1363WithSanction = IERC1363WithSanction(loadSavedDeployedAddress('ERC1363WithSanction'));
    }

}