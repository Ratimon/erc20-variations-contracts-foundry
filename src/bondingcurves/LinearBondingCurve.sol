// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {IBondingCurve} from "@main/interfaces/IBondingCurve.sol";

import {BondingCurve} from "@main/bondingcurves/BondingCurve.sol";
import {LinearCurve} from "@main/pricings/LinearCurve.sol";

import { UD60x18,ud, unwrap} from "@prb-math/UD60x18.sol";

contract LinearBondingCurve is BondingCurve, LinearCurve {
    /**
     * @notice linear bondingCurve constructor
     * @param _acceptedToken ERC1337 token in for this bonding curve
     * @param _token ERC20 token sale out for this bonding curve
     * @param _cap maximum token sold for this bonding curve to ensure security
     * @param _slope slope for this bonding curve
     * @param _initialPrice initial price for this bonding curve
     */
    constructor(
        IERC1363 _acceptedToken,
        IERC20 _token,
        uint256 _cap,
        uint256 _slope,
        uint256 _initialPrice
        ) BondingCurve(_acceptedToken,_token,_cap) LinearCurve(_slope, _initialPrice){

    }

    /**
     * @notice return current instantaneous bonding curve price
     * @return amountOut price reported 
     * @dev just use only one helper function from LinearCurve
    **/
    function getCurrentPrice() external view override returns (UD60x18){
        return getLinearInstantaneousPrice(totalPurchased);
    }

    /**
     * @notice return amount of token received after a bonding curve purchase
     * @param amountIn the amount of underlying used to purchase
     * @return amountOut the amount of sale token received
     * @dev retained poolBalance (i.e. after including the next set of added tokensupply) minus current poolBalance
    **/
    function calculatePurchasingAmountOut(UD60x18 amountIn)
        public
        view
        override
        returns(UD60x18 amountOut) {
            return getPoolBalance(totalPurchased.add(amountIn)).sub(getPoolBalance(totalPurchased));
    }

    /**
     * @notice return amount of acceptable token received after a bonding curve buyback
     * @param amountIn the amount of token sale used to buybacl
     * @return amountOut the amount of acceptable token received
     * @dev retained poolBalance (i.e. after including the next set of reduced tokensupply) minus current poolBalance
    **/
    function calculateBuyingBackAmountOut(UD60x18 amountIn)
        public
        view
        override
        returns(UD60x18 amountOut) {
            return getPoolBalance(totalPurchased).sub(getPoolBalance(totalPurchased.add(amountIn)));
    }
}

