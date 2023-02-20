// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Test} from "@forge-std/Test.sol";
import {RegisterScripts, console} from "@script/RegisterScripts.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {IBondingCurve} from "@main/interfaces/IBondingCurve.sol";
import {IERC1363WithSanction} from "@main/interfaces/IERC1363WithSanction.sol";

import {MockERC20} from  "@solmate/test/utils/mocks/MockERC20.sol";

import {BondingCurve} from "@main/bondingcurves/BondingCurve.sol";
import {ERC1363WithSanction} from "@main/ERC1363WithSanction.sol";
import {LinearBondingCurve} from "@main/bondingcurves/LinearBondingCurve.sol";

import { unwrap } from "@prb-math/UD60x18.sol";

contract TestUnitLinearBondingCurve is Test, RegisterScripts {

    address deployer;
    address alice = address(1);
    address bob = address(2);
    address carol = address(3);
    address dave = address(4);


    struct Constructors_erc1363WithSanction {
        string name;
        string symbol;
        address initialOwner;
        address initialSanctionAdmin;
        address initialMinter;
    }
    Constructors_erc1363WithSanction arg_erc1363WithSanction;
    IERC1363WithSanction erc1363WithSanction;


    struct Constructors_linearBondingCurve {
        IERC1363 acceptedToken;
        IERC20 token;
        uint256 _cap;
        uint256 _slope;
        uint256 _initialPrice;
    }
    Constructors_linearBondingCurve arg_linearBondingCurve;
    IBondingCurve linearBondingCurve;

    MockERC20 mockToken;
    IERC20 saleToken;


    function setUpScripts() internal virtual override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public virtual {

        vm.label(address(this), "TestUnitLinearBondingCurve");

        deployer = msg.sender;
        vm.label(deployer, "Deployer");


        vm.label(alice, "Alice");
        vm.label(bob, "Bob");

        deal(alice, 1 ether);
        deal(bob, 1 ether);

        arg_erc1363WithSanction.name = "Test Sanction Token";
        arg_erc1363WithSanction.symbol = "SANC";
        arg_erc1363WithSanction.initialOwner = msg.sender;
        arg_erc1363WithSanction.initialSanctionAdmin = msg.sender;
        arg_erc1363WithSanction.initialMinter = msg.sender;

        erc1363WithSanction = new ERC1363WithSanction(
            arg_erc1363WithSanction.name,
            arg_erc1363WithSanction.symbol,
            arg_erc1363WithSanction.initialOwner,
            arg_erc1363WithSanction.initialSanctionAdmin,
            arg_erc1363WithSanction.initialMinter
        );
         vm.label(address(erc1363WithSanction), "erc1363WithSanction");


        mockToken = new MockERC20("TestSaleToken", "TT0", 18);
        saleToken = IERC20(address(mockToken));
        vm.label(address(saleToken), "TestSaleToken");

        vm.startPrank(deployer);

        // arg_linearBondingCurve.acceptedToken = address(erc1363WithSanction);
        // arg_linearBondingCurve.token = address(saleToken);
        arg_linearBondingCurve.acceptedToken = IERC1363(address(erc1363WithSanction));
        arg_linearBondingCurve.token = IERC20(address(saleToken));
        arg_linearBondingCurve._cap = 1_000_000;
        arg_linearBondingCurve._slope = 1.5e18;
        arg_linearBondingCurve._initialPrice = 30e18;

        
        linearBondingCurve = new LinearBondingCurve(
            arg_linearBondingCurve.acceptedToken,
            arg_linearBondingCurve.token, 
            arg_linearBondingCurve._cap,
            arg_linearBondingCurve._slope,
            arg_linearBondingCurve._initialPrice
        );

        vm.label(address(linearBondingCurve), "linearBondingCurve");

       

        uint256 maxTokens = type(uint256).max;
        IERC20(saleToken).approve(address(linearBondingCurve),maxTokens);

        deal({token : address(saleToken), to: deployer, give: arg_linearBondingCurve._cap });

        linearBondingCurve.init();

        vm.stopPrank();
    }

    // /// @dev Checks common assumptions for the tests below.
    // function checkAssumptions(address owner, address to, uint256 amount0) internal pure {
    //     vm.assume(owner != address(0) && to != address(0));
    //     vm.assume(owner != to);
    //     vm.assume(amount0 > 0);
    // }

    function test_Constructor() public {
        assertEq( unwrap(linearBondingCurve.cap()), IERC20(saleToken).balanceOf(address(linearBondingCurve)) );
    }

}