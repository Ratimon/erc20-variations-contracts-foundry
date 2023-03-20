// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IAccount} from "@main/interfaces/IAccount.sol";


/**
 * @notice abstract contract for withdrawing ERC-20 tokens & ETH
 * @dev derived contract must implement state-changing api
**/
abstract contract Account is IAccount {

    using SafeERC20 for IERC20;

    /**
     * @notice withdraw ERC20 from the contract
     * @param token address of the ERC20 to send
     * @param to address destination of the ERC20
     * @param amount quantity of ERC20 to send
     * @dev derived contract may overide this i.e. include modifer for access control
    **/
    function withdrawERC20(
      address token, 
      address to, 
      uint256 amount
    ) external virtual override {
        _withdrawERC20(token, to, amount);
    }

    function _withdrawERC20(
      address token, 
      address to, 
      uint256 amount
    ) internal {
        IERC20(token).safeTransfer(to, amount);
        emit WithdrawERC20(msg.sender, token, to, amount);
    }


    /**
     * @notice withdraw ETH from the contract
     * @param to address to send ETH
     * @param amountOut amount of ETH to send
     * @dev derived contract may overide this i.e. include modifer for access control
    **/
    function withdrawETH(address payable to, uint256 amountOut) external virtual override {
        _withdrawETH(to,amountOut);
    }


    function _withdrawETH(address payable to, uint256 amountOut) internal  {
        Address.sendValue(to, amountOut);
        emit WithdrawETH(msg.sender, to, amountOut);
    }

}

