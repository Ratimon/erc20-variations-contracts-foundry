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

import {DeploymentERC1363WithSanction}  from "@test/unit/utils/ERC1363WithSanction.constructor.sol";
import {DeploymentLinearBondingCurve}  from "@test/unit/utils/LinearBondingCurve.constructor.sol";

contract Deployer is  DeploymentERC1363WithSanction, DeploymentLinearBondingCurve {

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
        IBondingCurve(address(linearBondingCurve)).init();
    }

}

contract EchidnaFuzzLinearBondingCurve {

    address echidna_caller = msg.sender;

    address erc1363WithSanction;
    address saleToken;
    address linearBondingCurve;

    constructor() public {
        (erc1363WithSanction, saleToken, linearBondingCurve) = (new Deployer()).deployAll();
    }

    // function echidna_test_curve() public view returns (bool) {
    //     return linearBondingCurve();
    // }

}

