// SPDX-License-Identifier: MIT

pragma solidity  =0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {IBondingCurve} from "@main/interfaces/IBondingCurve.sol";

import {ERC1363PayableBase} from "@main/base/ERC1363PayableBase.sol";

contract BondingCurve is IBondingCurve, ERC1363PayableBase {

    // @notice the ERC20 token sale for this bonding curve
    IERC20 public override immutable token;

    /**
     * @notice the total amount of token purchased on bonding curve
    **/
    uint256 public override totalPurchased;

    /**
     * @notice BondingCurve constructor
     * @param acceptedToken ERC20 token in for this bonding curve
     * @param _token ERC20 token sale out for this bonding curve
    **/
    constructor(
        IERC1363 acceptedToken,
        IERC20 _token
        ) ERC1363PayableBase(acceptedToken){

        token = _token;

    }

    /**
     * @notice return current instantaneous bonding curve price
     * @return amountOut price reported 
     * @dev just use only one helper function from LinearCurve
    **/
    function getCurrentPrice() external view returns (uint256){
        return 1;
    }

    /**
     * @notice return amount of token received after a bonding curve purchase
     * @param amountIn the amount of underlying used to purchase
     * @return amountOut the amount of token received
    **/
    function getAmountOut(uint256 amountIn)
        external
        view
        returns (uint256 amountOut) {
            return 1;
    }


    /**
     *@notice balance of the bonding curve
     *@return the amount of token held in contract and ready to be allocated
    **/
    function balance() public view virtual override returns (uint256) {
        return token.balanceOf(address(this));
    }


}