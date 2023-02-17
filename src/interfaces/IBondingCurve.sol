// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBondingCurve {
    // ----------- Events -----------

    // ----------- State changing Api -----------

    // ----------- Governor only state changing api -----------

    function pause() external;

    function unpause() external;

    // ----------- Getters -----------

    function getCurrentPrice() external view returns (uint256);

    function getAmountOut(uint256 amountIn)
        external
        view
        returns (uint256 amountOut);

    function totalPurchased() external view returns (uint256);

    function balance() external view returns (uint256);

    function token() external view returns (IERC20);

}