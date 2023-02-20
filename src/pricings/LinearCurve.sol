// SPDX-License-Identifier: MIT
pragma solidity  =0.8.17;

import { powu } from "@prb-math/ud60x18/Math.sol";
import { UD60x18, ud } from "@prb-math/UD60x18.sol";

/**
 * @notice abstract contract for calcuting curve
 * @dev functioncal components could be used in derived contract
**/
contract LinearCurve {

    /**
     * @notice the curve slope
     * @dev refer to price = slope * currentTokenPurchased + initialPrice
    **/
    UD60x18 public immutable slope;

    /**
     * @notice the token price when there purchased token is zero
     * @dev refer to the instantaneous price = slope * currentTokenPurchased + initialPrice
    **/
    UD60x18 public immutable initialPrice;

    /**
     * @notice BondingCurve constructor
     * @param _slope slope for this bonding curve
     * @param _initialPrice initial price for this bonding curve
    **/
    constructor(
        uint256 _slope,
        uint256 _initialPrice
        ) {
        slope =  ud(_slope);
        initialPrice = ud(_initialPrice);
    }

    /**
     * @notice return instantaneous bonding curve price
     * @return the instantaneous price = slope * currentTokenPurchased + initialPrice
    **/
    function getLinearInstantaneousPrice(UD60x18 tokenSupply) public view returns (UD60x18){
        return slope.mul(tokenSupply).add(initialPrice);
    }

    /**
     * @notice return the pool balance or the amount of the reserve currency
     * @param tokenSupply the token supply
     * @return the total token price reported 
     * @dev integral of price regarding to tokensupply : integral =  slope/2 * (currentTokenPurchased)^2 + initialPrice * (currentTokenPurchased)
    **/
    function getPoolBalance(UD60x18 tokenSupply) public view returns (UD60x18){
        return slope.mul(powu(tokenSupply,2)).div(ud(2e18)).add(tokenSupply.mul(initialPrice)) ;
    }


}