// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeploymentTokenSale {

    struct Constructors_tokenSale {
        IERC20 token;
        uint256 _cap;
        uint256 _price;
    }

    Constructors_tokenSale arg_tokenSale;

}