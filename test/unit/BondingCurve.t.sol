// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Test} from "@forge-std/Test.sol";
import {RegisterScripts, console} from "@script/RegisterScripts.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {IBondingCurve} from "@main/interfaces/IBondingCurve.sol";

import {BondingCurve} from "@main/bondingcurves/BondingCurve.sol";
import {LinearBondingCurve} from "@main/bondingcurves/LinearBondingCurve.sol";

contract TestUnitBondingCurve is Test, RegisterScripts {

    address deployer;
    address alice = address(1);
    address bob = address(2);
    address carol = address(3);
    address dave = address(4);

    struct Constructors {
        string name;
        string symbol;
        address initialOwner;
        address initialSanctionAdmin;
    }
    Constructors arguments;

    IBondingCurve linearBondingCurve;

    function setUpScripts() internal virtual override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public virtual {
        vm.label(address(this), "TestUnitBondingCurve");
        deployer = msg.sender;
        vm.label(deployer, "Deployer");

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");

        deal(alice, 1 ether);
        deal(bob, 1 ether);

        // arguments.name = "Test Sanction Token";
        // arguments.symbol = "SANC";
        // arguments.initialOwner = msg.sender;
        // arguments.initialSanctionAdmin = msg.sender;

        // linearBondingCurve = new LinearBondingCurve(arguments.name, arguments.symbol,  arguments.initialOwner, arguments.initialSanctionAdmin);
    }

}