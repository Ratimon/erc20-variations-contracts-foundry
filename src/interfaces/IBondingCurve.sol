// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { UD60x18, ud } from "@prb-math/UD60x18.sol";

interface IBondingCurve {
    // ----------- Events -----------

    event CapUpdate(UD60x18 oldAmount, UD60x18 newAmount);

    event Purchase(address indexed operator, address indexed to, UD60x18 amountIn, UD60x18 amountOut);

    event Buyback(address indexed operator, address indexed to, UD60x18 amountIn, UD60x18 amountOut);

    event Allocate( address indexed caller, UD60x18 amount);

    event Reset(UD60x18 oldTotalPurchased);

    // ----------- State changing Api -----------

    function purchase(address to, uint256 amountIn)
        external
        payable
        returns (UD60x18 amountOut);

    function buyback(address to, uint256 amountIn)
        external
        payable
        returns (UD60x18 amountOut);

    // ----------- Governor only state changing api -----------

    function init() external;

    function allocate(uint256 amount, address to) external;

    function pause() external;

    function unpause() external;

    function reset() external;

    function setCap(UD60x18 newCap) external;

    // ----------- Getters -----------

    function getCurrentPrice() external view returns (UD60x18);

    function calculatePurchaseAmountOut(UD60x18 tokenAmountIn)
        external
        view
        returns (UD60x18 balanceAmountOut);

    function calculateBuybackAmountOut(UD60x18 balanceAmountIn)
        external
        view
        returns (UD60x18 tokenAmountOut);

    function totalPurchased() external view returns (UD60x18);

    function cap() external view returns (UD60x18);

    function availableToSell() external view returns (UD60x18);

    function reserveBalance() external view returns (UD60x18);

    function token() external view returns (IERC20);

}