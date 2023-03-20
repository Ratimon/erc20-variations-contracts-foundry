// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {IBondingCurve} from "@main/interfaces/IBondingCurve.sol";
import {IERC1363WithSanction} from "@main/interfaces/IERC1363WithSanction.sol";

import {Test} from "@forge-std/Test.sol";
import {StdInvariant} from "@forge-std/StdInvariant.sol";

import {ERC1363WithSanction} from "@main/ERC1363WithSanction.sol";

import {MockERC20} from  "@solmate/test/utils/mocks/MockERC20.sol";
import {UD60x18, ud, unwrap } from "@prb-math/UD60x18.sol";

import {ConstantsFixture}  from "@test/unit/utils/ConstantsFixture.sol";
import {DeploymentERC1363WithSanction}  from "@test/unit/utils/ERC1363WithSanction.constructor.sol";
import {DeploymentLinearBondingCurve}  from "@test/unit/utils/LinearBondingCurve.constructor.sol";

import { InvariantOwner }   from "./handlers/Owner.sol";
import { InvariantBuyerManager }   from "./handlers/Buyer.sol";


// Invariant 1: totalPurchased + avalableToSell = cap
// Invariant 2: avalableToSell >= 0
// Invariant 3: avalableToSell = IERC20(token).balanceOf(curve)
// Invariant 4: Poolbalance =   y = f(x = supply) =  slope/2 * (currentTokenPurchased)^2 + initialPrice * (currentTokenPurchased)

contract LinearBondingCurveInvariants is StdInvariant, Test, ConstantsFixture, DeploymentERC1363WithSanction, DeploymentLinearBondingCurve  {

    InvariantOwner internal _owner;
    InvariantBuyerManager internal _buyerManager;

    IERC20 buyToken;
    IERC20 saleToken;
    IBondingCurve linearBondingCurve;

    function setUp() public override {
        vm.label(address(this), "LinearBondingCurveInvariants");

        vm.startPrank(deployer);

        // owner
        // buyer
        // warper

        arg_erc1363WithSanction.name = "TestBuyToken";
        arg_erc1363WithSanction.symbol = "BUY";
        arg_erc1363WithSanction.initialOwner = msg.sender;
        arg_erc1363WithSanction.initialSanctionAdmin = msg.sender;
        arg_erc1363WithSanction.initialMinter = msg.sender;

        buyToken = new ERC1363WithSanction(
            arg_erc1363WithSanction.name,
            arg_erc1363WithSanction.symbol,
            arg_erc1363WithSanction.initialOwner,
            arg_erc1363WithSanction.initialSanctionAdmin,
            arg_erc1363WithSanction.initialMinter
        );

        saleToken = IERC20(address(new MockERC20("TestSaleToken", "SELL", 18)));
        

        arg_linearBondingCurve.acceptedToken = IERC1363(address(buyToken));
        arg_linearBondingCurve.token = IERC20(address(saleToken));
        arg_linearBondingCurve._cap = 1_000_000e18;
        arg_linearBondingCurve._slope = 1.5e18;
        arg_linearBondingCurve._initialPrice = 30e18;

        linearBondingCurve = IBondingCurve(DeploymentLinearBondingCurve.deployAndSetup(saleToken,  deployer, arg_linearBondingCurve, dealERC20 ));

        vm.label(address(buyToken), "TestBuyToken");
        vm.label(address(saleToken), "TestSaleToken");
        vm.label(address(linearBondingCurve), "linearBondingCurve");

        vm.stopPrank();

        _owner = new InvariantOwner(address(linearBondingCurve), address(buyToken),  address(saleToken));
        _buyerManager = new InvariantBuyerManager(address(linearBondingCurve), address(buyToken),  address(saleToken));

        vm.label(address(_owner), "Owner");
        vm.label(address(_buyerManager), "BuyerManager");

        // bytes4[] memory selectors = new bytes4[](1);
        // selectors[0] = Handler.__.selector;
        // targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));

        targetContract(address(_owner));
        targetContract(address(_buyerManager));

        _buyerManager.createBuyer();
    }

    function dealERC20(address saleToken_, address deployer_, uint256 cap_ ) internal {
        deal({token : saleToken_, to: deployer_, give: cap_ });
    }

    // function deal(address token, address to, uint256 give) internal virtual {

    function test_Constructor() public {
        assertEq( unwrap(linearBondingCurve.cap()), IERC20(saleToken).balanceOf(address(linearBondingCurve)) );
    }

    // Invariant 1: totalPurchased + avalableToSell = cap
    function invariant_totalPurchasedPlusAvalableToSell_eq_cap() public {
        assertEq( unwrap(linearBondingCurve.totalPurchased().add(linearBondingCurve.availableToSell())), unwrap(linearBondingCurve.cap()) );
    }



}