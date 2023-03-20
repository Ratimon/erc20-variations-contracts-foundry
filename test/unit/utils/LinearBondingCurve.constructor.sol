// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";

contract DeploymentLinearBondingCurve {

    struct Constructors_linearBondingCurve {
        IERC1363 acceptedToken;
        IERC20 token;
        uint256 _cap;
        uint256 _slope;
        uint256 _initialPrice;
    }

    Constructors_linearBondingCurve arg_linearBondingCurve;

}