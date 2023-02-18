// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBondingCurve {
    // ----------- Events -----------

    event MintCapUpdate(uint256 oldMint, uint256 newMint);

    event Purchase(address indexed operator, address indexed to, uint256 amountIn, uint256 amountOut);

    event Allocate( address indexed caller, uint256 amount);

    event Reset(uint256 oldTotalPurchased);


    // ----------- State changing Api -----------

    function purchase(address to, uint256 amountIn)
        external
        payable
        returns (uint256 amountOut);

    // ----------- Governor only state changing api -----------

    function allocate(uint256 amount, address to) external;

    function pause() external;

    function unpause() external;

    function reset() external;

    function setMintCap(uint256 newMintCap) external;

    // ----------- Getters -----------

    function getCurrentPrice() external view returns (uint256);

    function getAmountOut(uint256 amountIn)
        external
        view
        returns (uint256 amountOut);

    function totalPurchased() external view returns (uint256);

    function mintCap() external view returns (uint256);

    function availableToMint() external view returns (uint256);

    function reserveBalance() external view returns (uint256);

    function token() external view returns (IERC20);

}