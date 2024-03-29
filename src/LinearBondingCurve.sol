// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {IBondingCurve} from "@main/interfaces/IBondingCurve.sol";

import {BondingCurve} from "@main/bondingcurves/BondingCurve.sol";
import {LinearCurve} from "@main/pricings/LinearCurve.sol";

import {UD60x18, ud, unwrap} from "@prb-math/UD60x18.sol";

contract LinearBondingCurve is BondingCurve, LinearCurve {
    /**
     * @notice linear bondingCurve constructor
     * @param _acceptedToken ERC1337 token in for this bonding curve
     * @param _token ERC20 token sale out for this bonding curve
     * @param _duration duration to sell
     * @param _cap maximum token sold for this bonding curve to ensure security
     * @param _slope slope for this bonding curve
     * @param _initialPrice initial price for this bonding curve
     */
    constructor(
        IERC1363 _acceptedToken,
        IERC20 _token,
        uint256 _duration,
        uint256 _cap,
        uint256 _slope,
        uint256 _initialPrice
    ) BondingCurve(_acceptedToken, _token, _duration, _cap) LinearCurve(_slope, _initialPrice) {}

    /**
     * @notice return current instantaneous bonding curve price
     * @param tokenSupply the current amount of acceptable token purchased
     * @return amountOut price reported
     * @dev just use only one helper function from LinearCurve
     *
     */
    function getCurrentPrice(UD60x18 tokenSupply) external view override returns (UD60x18) {
        return getLinearInstantaneousPrice(tokenSupply);
    }

    /**
     * @notice return amount of token sale received after a bonding curve purchase
     * @param tokenAmountIn the amount of underlying used to purchase
     * @return balanceAmountOut the amount of sale token received
     * @dev retained poolBalance (i.e. after including the next set of added token supply) minus current poolBalance
     *
     */
    function calculatePurchaseAmountOut(UD60x18 tokenAmountIn)
        public
        view
        override
        returns (UD60x18 balanceAmountOut)
    {
        return getPoolBalance(totalPurchased.add(tokenAmountIn)).sub(getPoolBalance(totalPurchased));
    }
}
