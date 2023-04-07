// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {IBondingCurve} from "@main/interfaces/IBondingCurve.sol";
import {IERC1363WithSanction} from "@main/interfaces/IERC1363WithSanction.sol";

import {Test} from "@forge-std/Test.sol";
import {StdInvariant} from "@forge-std/StdInvariant.sol";

import {MockERC20} from  "@solmate/test/utils/mocks/MockERC20.sol";
import {UD60x18, ud, unwrap } from "@prb-math/UD60x18.sol";

import {ConstantsFixture}  from "@test/unit/utils/ConstantsFixture.sol";
import {DeploymentERC1363WithSanction}  from "@test/unit/utils/ERC1363WithSanction.constructor.sol";
import {DeploymentLinearBondingCurve}  from "@test/unit/utils/LinearBondingCurve.constructor.sol";

import { InvariantOwner }   from "./handlers/Owner.sol";
import { InvariantBuyerManager }   from "./handlers/Buyer.sol";
import { Warper }  from "./handlers/Warper.sol";

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {LinearCurve} from "@main/pricings/LinearCurve.sol";

// Invariant 1: totalPurchased + avalableToSell = cap
// Invariant 2: avalableToSell >= 0
// Invariant 3: avalableToSell = IERC20(token).balanceOf(curve)
// Invariant 4: Poolbalance =   y = f(x = supply) =  slope/2 * (currentTokenPurchased)^2 + initialPrice * (currentTokenPurchased)

contract LinearBondingCurveInvariants is StdInvariant, Test, ConstantsFixture, DeploymentERC1363WithSanction, DeploymentLinearBondingCurve  {

    InvariantOwner internal _owner;
    InvariantBuyerManager internal _buyerManager;
    Warper internal _warper;

    IERC20 buyToken;
    IERC20 saleToken;
    IBondingCurve linearBondingCurve;

    function setUp() public override {
        super.setUp();
        vm.label(address(this), "LinearBondingCurveInvariants");

        vm.startPrank(deployer);
        vm.warp(staticTime );

        arg_erc1363WithSanction.name = "TestBuyToken";
        arg_erc1363WithSanction.symbol = "BUY";
        arg_erc1363WithSanction.initialOwner = msg.sender;
        arg_erc1363WithSanction.initialSanctionAdmin = msg.sender;
        arg_erc1363WithSanction.initialMinter = msg.sender;
        buyToken = IERC20(DeploymentERC1363WithSanction.deployAndSetup( arg_erc1363WithSanction ));

        saleToken = IERC20(address(new MockERC20("TestSaleToken", "SELL", 18)));

        arg_linearBondingCurve.acceptedToken = IERC1363(address(buyToken));
        arg_linearBondingCurve.token = IERC20(address(saleToken));
        arg_linearBondingCurve._duration = 1 weeks;
        arg_linearBondingCurve._cap = 1_000_000e18;
        arg_linearBondingCurve._slope = 1.5e18;
        arg_linearBondingCurve._initialPrice = 30e18;
        linearBondingCurve = IBondingCurve(DeploymentLinearBondingCurve.deployAndSetup(saleToken,  deployer, arg_linearBondingCurve, dealERC20 ));

        vm.label(address(buyToken), "TestBuyToken");
        vm.label(address(saleToken), "TestSaleToken");
        vm.label(address(linearBondingCurve), "linearBondingCurve");

        _buyerManager = new InvariantBuyerManager(address(linearBondingCurve), address(buyToken),  address(saleToken) );
        _warper = new Warper(address(linearBondingCurve));
        _owner = new InvariantOwner(address(linearBondingCurve), address(buyToken), address(saleToken), staticTime);
        
        vm.label(address(_buyerManager), "BuyerManager");
        vm.label(address(_warper), "Warper");
        vm.label(address(_owner), "Owner");
       
        Ownable2Step(address(linearBondingCurve)).transferOwnership(address(_owner));
        vm.stopPrank();

        vm.startPrank(address(_owner));
        Ownable2Step(address(linearBondingCurve)).acceptOwnership();
        vm.stopPrank();

        vm.startPrank(deployer);
        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = InvariantBuyerManager.purchase.selector;

        // Performs random purchase() calls
        targetSelector(FuzzSelector({addr: address(_buyerManager), selectors: selectors}));
        targetContract(address(_buyerManager));

        selectors[0] = Warper.warp.selector;
        // Performs random warps forward in time
        targetSelector(FuzzSelector({addr: address(_warper), selectors: selectors}));
        targetContract(address(_warper));

        selectors[0] = InvariantOwner.allocate.selector;
        // Performs random allocate() calls
        targetSelector(FuzzSelector({addr: address(_owner), selectors: selectors}));
        targetContract(address(_owner));

        _buyerManager.createBuyer();
        vm.stopPrank();
       
    }

    function dealERC20(address saleToken_, address deployer_, uint256 cap_ ) internal {
        deal({token : saleToken_, to: deployer_, give: cap_ });
    }

    function test_Constructor() public {
        assertEq( unwrap(linearBondingCurve.cap()), IERC20(saleToken).balanceOf(address(linearBondingCurve)) );
    }

    // Invariant 1: totalPurchased + avalableToSell = cap
    function invariant_totalPurchasedPlusAvalableToSell_eq_cap() public {
        assertEq( unwrap(linearBondingCurve.totalPurchased().add(linearBondingCurve.availableToSell())), unwrap(linearBondingCurve.cap()) );
    }

    // Invariant 2: avalableToSell >= 0
    function invariant_AvalableToSell_gt_zero() public {
        assertGt( unwrap(linearBondingCurve.availableToSell()), 0 );
    }

    // Invariant 3: avalableToSell = IERC20(token).balanceOf(curve)
    function invariant_AvalableToSell_eq_saleTokenBalance() public {
        assertEq( unwrap(linearBondingCurve.availableToSell()), IERC20(saleToken).balanceOf(address(linearBondingCurve)) );
    }

    // Invariant 4: Poolbalance =   y = f(x = supply) =  slope/2 * (currentTokenPurchased)^2 + initialPrice * (currentTokenPurchased)
    function invariant_Poolbalance_eq_saleTokenBalance() public {

        UD60x18 buyTokenSupply = ud( IERC20(buyToken).balanceOf(address(linearBondingCurve)) );

        assertEq( unwrap( LinearCurve( address(linearBondingCurve)).getPoolBalance( buyTokenSupply ) ), unwrap(linearBondingCurve.totalPurchased() ));
    }

    function invariant_callSummary() public view {
        _buyerManager.callSummary();
        _warper.callSummary();
        _owner.callSummary();
        

    }



}