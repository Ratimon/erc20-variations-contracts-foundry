// SPDX-License-Identifier: MIT
pragma solidity  =0.8.17;

abstract contract LinerCurve {

    /**
     * @notice the curve slope
     * @dev refer to price = slope * currentTokenPurchased + initialPrice
    **/
    uint256 public immutable slope;

    /**
     * @notice the token price when there purchased token is zero
     * @dev refer to price = slope * currentTokenPurchased + initialPrice
    **/
    uint256 public immutable initialPrice;

    /**
     * @notice BondingCurve constructor
     * @param _slope slope for this bonding curve
     * @param _initialPrice initial price for this bonding curve
    **/
    constructor(
        uint256 _slope,
        uint256 _initialPrice
        ) {
        slope =  _slope;
        initialPrice = _initialPrice;
    }

    /**
     * @notice return instantaneous bonding curve price
     * @return amountOut price reported 
    **/
    function getInstantaneousPrice() external pure returns (uint256){
        return 1;
    }

        /**
     * @notice return the pool balance or the amount of the reserve currency
     * @param tokenSupply the token supply
     * @return the total token price reported 
     * @dev integral of price regarding to tokensupply
    **/
    function getPoolBalance(uint256 tokenSupply) external pure returns (uint256){
        return 1;
    }




}