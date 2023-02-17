// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

contract Constants {
    uint256 public constant WAD = 1e18;

    // string public constant LOCALHOST = "LOCALHOST";
    // string public constant MAINNET = "MAINNET";
    // string public constant ARBITRUM = "ARBITRUM";
    // string public constant TENDERLY = "TENDERLY";
    // string public constant MOCK = "MOCK";
    // string public constant NETWORK = "NETWORK";

    mapping (string => mapping (string => address)) public addresses;

    constructor() {
        // addresses[MOCK][TIMELOCK] = ;
    }
}