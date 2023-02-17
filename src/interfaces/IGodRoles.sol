// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

interface IGodRoles {

    // ----------- Governor only state changing api -----------

    function transferOwnership(address newOwner) external;
    function setGod(address newGod) external;

    // ----------- State changing Api -----------

    function acceptOwnership() external;
    function acceptGod() external;

    // ----------- Getters -----------

    function owner() external view returns (address);
    function pendingOwner() external view returns (address);

    function god() external view returns (address);
    function pendingGod() external view returns (address);

}