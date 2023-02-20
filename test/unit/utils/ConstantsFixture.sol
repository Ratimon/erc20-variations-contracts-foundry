// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

contract ConstantsFixture {
    uint256 public constant WAD = 1e18;

    uint256 constant maxUint256 = type(uint256).max;
    mapping (string => mapping (string => address)) public addresses;

    address public deployer;
    address public alice = address(1);
    address public bob = address(2);
    address public carol = address(3);
    address public dave = address(4);

}