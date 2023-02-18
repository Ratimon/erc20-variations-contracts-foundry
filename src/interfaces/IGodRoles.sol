// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

interface IGodRoles {

    // ----------- Events -----------

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event GodSetStarted(address indexed previousGod, address indexed newGod);
    event GodSet(address indexed previousGod, address indexed newGod);

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