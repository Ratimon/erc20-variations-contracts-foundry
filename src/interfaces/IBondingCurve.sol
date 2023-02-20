// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { UD60x18, ud } from "@prb-math/UD60x18.sol";

interface IBondingCurve {
    // ----------- Events -----------

    event MintCapUpdate(UD60x18 oldMint, UD60x18 newMint);

    event Purchase(address indexed operator, address indexed to, UD60x18 amountIn, UD60x18 amountOut);

    event Allocate( address indexed caller, UD60x18 amount);

    event Reset(UD60x18 oldTotalPurchased);


    // ----------- State changing Api -----------

    function purchase(address to, uint256 amountIn)
        external
        payable
        returns (UD60x18 amountOut);

    // ----------- Governor only state changing api -----------

    function allocate(uint256 amount, address to) external;

    function pause() external;

    function unpause() external;

    function reset() external;

    function setMintCap(UD60x18 newMintCap) external;

    // ----------- Getters -----------

    function getCurrentPrice() external view returns (UD60x18);

    function calculatePurchasingAmountOut(UD60x18 amountIn)
        external
        view
        returns (UD60x18 amountOut);

    function totalPurchased() external view returns (UD60x18);

    function mintCap() external view returns (UD60x18);

    function availableToMint() external view returns (UD60x18);

    function reserveBalance() external view returns (UD60x18);

    function token() external view returns (IERC20);

}