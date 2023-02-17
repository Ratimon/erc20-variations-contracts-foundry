// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {console} from "@script/RegisterScripts.sol";

import {ERC1363WithSanction} from "@main/ERC1363WithSanction.sol";
import {TestERC1363WithSanction} from "@test/integration/ERC1363WithSanction.t.sol";


contract TestUnitERC1363WithSanction is TestERC1363WithSanction {


    struct Constructors {
        string name;
        string symbol;
        address initialOwner;
        address initialSanctionAdmin;
        address initialMinter;
    }

    Constructors arguments;

    function setUpScripts() internal override(TestERC1363WithSanction) {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public override {

        arguments.name = "Test Sanction Token";
        arguments.symbol = "SANC";
        arguments.initialOwner = msg.sender;
        arguments.initialSanctionAdmin = msg.sender;
        arguments.initialMinter = msg.sender;

        deployer = msg.sender;
        vm.label(deployer, "Deployer");

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(address(this), "TestERC1363WithSanction");

        deal(alice, 1 ether);
        deal(bob, 1 ether);
        // ERC1363WithSanction = new ERC1363WithSanction(loadSavedDeployedAddress('ERC1363WithSanction'));
        erc1363WithSanction = new ERC1363WithSanction(arguments.name, arguments.symbol,  arguments.initialOwner, arguments.initialSanctionAdmin, arguments.initialMinter);
    }



}