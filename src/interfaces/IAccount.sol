// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IAccount {
    // ----------- Events -----------
    event Deposit(address indexed _from, uint256 _amount);

    event Withdrawal(
        address indexed _caller,
        address indexed _to,
        uint256 _amount
    );

    event WithdrawERC20(
        address indexed _caller,
        address indexed _token,
        address indexed _to,
        uint256 _amount
    );

    event WithdrawETH(
        address indexed _caller,
        address indexed _to,
        uint256 _amount
    );

    // ----------- State changing api -----------

    function deposit() external;

   // ----------- Governor only state changing api -----------

    function withdraw(address to, uint256 amount) external;

    function withdrawERC20(address token, address to, uint256 amount) external;

    function withdrawETH(address payable to, uint256 amount) external;
    
    // ----------- Getters -----------

    function balance() external view returns (uint256);


}