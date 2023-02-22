// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {IBondingCurve} from "@main/interfaces/IBondingCurve.sol";
import {IERC1363WithSanction} from "@main/interfaces/IERC1363WithSanction.sol";

import {LinearCurve} from "@main/pricings/LinearCurve.sol";
import {BondingCurve} from "@main/bondingcurves/BondingCurve.sol";
import {ERC1363WithSanction} from "@main/ERC1363WithSanction.sol";
import {LinearBondingCurve} from "@main/LinearBondingCurve.sol";

import {MockERC20} from  "@solmate/test/utils/mocks/MockERC20.sol";
import {UD60x18, ud, unwrap } from "@prb-math/UD60x18.sol";

import {ConstantsFixture}  from "@test/unit/utils/ConstantsFixture.sol";
import {DeploymentERC1363WithSanction}  from "@test/unit/utils/ERC1363WithSanction.constructor.sol";
import {DeploymentLinearBondingCurve}  from "@test/unit/utils/LinearBondingCurve.constructor.sol";

contract TestUnitLinearBondingCurve is ConstantsFixture, DeploymentERC1363WithSanction, DeploymentLinearBondingCurve {

    IERC1363WithSanction erc1363WithSanction;
    IBondingCurve linearBondingCurve;

    MockERC20 mockToken;
    IERC20 saleToken;

    function setUpScripts() internal virtual override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public  virtual override {
        super.setUp();
        vm.label(address(this), "TestUnitLinearBondingCurve");

        vm.startPrank(deployer);
        
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

        arg_linearBondingCurve.acceptedToken = IERC1363(address(erc1363WithSanction));
        arg_linearBondingCurve.token = IERC20(address(saleToken));
        arg_linearBondingCurve._cap = 1_000_000e18;
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

        IERC20(saleToken).approve(address(linearBondingCurve),maxUint256);
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

    function test_purchase_stateSaleToken() public {
        deal({token : address(erc1363WithSanction), to: alice, give: 20e18 });

        vm.startPrank(alice);

        uint256 alicePreBalBuyingToken = IERC20(address(erc1363WithSanction)).balanceOf(alice);
        UD60x18 preReserveBalance = linearBondingCurve.reserveBalance();

        IERC20(address(erc1363WithSanction)).approve(address(linearBondingCurve), maxUint256);
        uint256 purchase_amount = 7e18;

        linearBondingCurve.purchase( alice, purchase_amount);

        uint256 alicePostBalBuyingToken = IERC20(address(erc1363WithSanction)).balanceOf(alice);
        UD60x18 postReserveBalance = linearBondingCurve.reserveBalance();
        uint256 changeInAliceBalBuyingToken = alicePostBalBuyingToken > alicePreBalBuyingToken ? (alicePostBalBuyingToken - alicePreBalBuyingToken) : (alicePreBalBuyingToken - alicePostBalBuyingToken);

        assertEq(alicePostBalBuyingToken, 13e18 );
        assertEq(changeInAliceBalBuyingToken, purchase_amount );
        assertEq(unwrap(postReserveBalance.sub(preReserveBalance)), purchase_amount );

        vm.stopPrank();
    }

    function test_purchase_stateBuyingToken() public {

        deal({token : address(erc1363WithSanction), to: alice, give: 20e18 });

        vm.startPrank(alice);

        uint256 alicePreBalSaleToken = IERC20(address(saleToken)).balanceOf(alice);
        UD60x18 preTotalPurchased = linearBondingCurve.totalPurchased();
        UD60x18 preAvailableToSell = linearBondingCurve.availableToSell();

        IERC20(address(erc1363WithSanction)).approve(address(linearBondingCurve), maxUint256);
        uint256 purchase_amount = 7e18;
        UD60x18 amountOut = linearBondingCurve.purchase( alice, purchase_amount);
        // 1.5/2*(7^2) + 30*(7) = 246.75

        uint256 alicePostBalSaleToken = IERC20(address(saleToken)).balanceOf(alice);
        UD60x18 postTotalPurchased = linearBondingCurve.totalPurchased();
        UD60x18 postAvailableToSell = linearBondingCurve.availableToSell();

        LinearCurve linearCurve =  LinearCurve(address(linearBondingCurve));
        
        UD60x18  postSaleTokenSupply = preTotalPurchased.add(ud(purchase_amount));
        UD60x18 firstIntegral = linearCurve.getPoolBalance(postSaleTokenSupply);
        UD60x18 secondIntegral = linearCurve.getPoolBalance(preTotalPurchased);
        UD60x18 changeInSaleToken = firstIntegral.sub(secondIntegral);

        assertEq(alicePostBalSaleToken, 246.75e18 );
        assertEq(alicePostBalSaleToken - alicePreBalSaleToken, unwrap(changeInSaleToken) );

        assertEq(unwrap(postTotalPurchased), 246.75e18 );
        assertEq(unwrap(postTotalPurchased), unwrap(amountOut) );
        assertEq(unwrap(postTotalPurchased.sub(preTotalPurchased)),unwrap(changeInSaleToken) );
        assertEq(unwrap(postAvailableToSell), unwrap(preAvailableToSell.sub(changeInSaleToken)));

        vm.stopPrank();
    }


}