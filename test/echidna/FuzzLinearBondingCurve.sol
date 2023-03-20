// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

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

import {DeploymentERC1363WithSanction}  from "@test/unit/utils/ERC1363WithSanction.constructor.sol";
import {DeploymentLinearBondingCurve}  from "@test/unit/utils/LinearBondingCurve.constructor.sol";

contract Deployer is  DeploymentERC1363WithSanction, DeploymentLinearBondingCurve {

    event Debug(uint256 index);

    address echidna_caller = msg.sender;

    function deployAll() public returns(address erc1363WithSanction, address saleToken,address linearBondingCurve) {

        arg_erc1363WithSanction.name = "Test Sanction Token";
        arg_erc1363WithSanction.symbol = "SANC";
        arg_erc1363WithSanction.initialOwner = msg.sender;
        arg_erc1363WithSanction.initialSanctionAdmin = msg.sender;
        arg_erc1363WithSanction.initialMinter = msg.sender;

        erc1363WithSanction = address(new ERC1363WithSanction(
            arg_erc1363WithSanction.name,
            arg_erc1363WithSanction.symbol,
            arg_erc1363WithSanction.initialOwner,
            arg_erc1363WithSanction.initialSanctionAdmin,
            arg_erc1363WithSanction.initialMinter
        ));

        saleToken = address(new MockERC20("TestSaleToken", "TT0", 18));

        arg_linearBondingCurve.acceptedToken = IERC1363(erc1363WithSanction);
        arg_linearBondingCurve.token = IERC20(saleToken);
        arg_linearBondingCurve._cap = 1_000_000e18;
        arg_linearBondingCurve._slope = 1.5e18;
        arg_linearBondingCurve._initialPrice = 30e18;
        
        linearBondingCurve = address(new LinearBondingCurve(
            arg_linearBondingCurve.acceptedToken,
            arg_linearBondingCurve.token, 
            arg_linearBondingCurve._cap,
            arg_linearBondingCurve._slope,
            arg_linearBondingCurve._initialPrice
        ));

        IERC20(saleToken).approve(address(linearBondingCurve),type(uint256).max);

        MockERC20(saleToken).mint( address(linearBondingCurve), arg_linearBondingCurve._cap);

        // IBondingCurve(address(linearBondingCurve)).init();
        emit Debug(2);
    }

}

contract EchidnaFuzzLinearBondingCurve {

    address echidna_caller = msg.sender;

    address erc1363WithSanction;
    address saleToken;
    address linearBondingCurve;

    constructor() {
        (erc1363WithSanction, saleToken, linearBondingCurve) = (new Deployer()).deployAll();
    }

    // system level

    // section: owner 
    
    // section: time

    // section: logic

    // Invariant 1: totalPurchased + avalableToSell = cap
    // Invariant 2: avalableToSeill >= 0
    // Invariant 3: avalableToSell = IERC20(token).balanceOf(curve)
    // Invariant 4: Poolbalance =   y = f(x = supply) =  slope/2 * (currentTokenPurchased)^2 + initialPrice * (currentTokenPurchased)

    function echidna_test_totalSupply_not_exceed_cap() public view {
        assert( IERC20(saleToken).balanceOf(linearBondingCurve) <= unwrap(IBondingCurve(linearBondingCurve).cap()) );
    }

    // function level

    // test_purchase

    // State before the "action"
    // uint256 prePurchaseBalance = stakerContract.stakedBalances(address(this));
    // Action
    // Post-condition

    // reserveBalance

}

