// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IBondingCurve} from "@main/interfaces/IBondingCurve.sol";

import {LinearBondingCurve} from "@main/LinearBondingCurve.sol";

contract DeploymentLinearBondingCurve {
    struct Constructors_linearBondingCurve {
        IERC1363 acceptedToken;
        IERC20 token;
        uint256 _duration;
        uint256 _cap;
        uint256 _slope;
        uint256 _initialPrice;
    }

    Constructors_linearBondingCurve arg_linearBondingCurve;

    function deployAndSetup(
        IERC20 saleToken_,
        address deployer,
        Constructors_linearBondingCurve storage arg_linearBondingCurve_,
        function(address, address, uint256 ) internal dealFunc
    ) internal returns (address linearBondingCurve) {
        linearBondingCurve = address(
            new LinearBondingCurve(
            arg_linearBondingCurve_.acceptedToken,
            arg_linearBondingCurve_.token, 
            arg_linearBondingCurve_._duration,
            arg_linearBondingCurve_._cap,
            arg_linearBondingCurve_._slope,
            arg_linearBondingCurve_._initialPrice
            )
        );

        saleToken_.approve(linearBondingCurve, type(uint256).max);
        dealFunc(address(saleToken_), deployer, arg_linearBondingCurve_._cap);
        IBondingCurve(linearBondingCurve).init();
    }
}
