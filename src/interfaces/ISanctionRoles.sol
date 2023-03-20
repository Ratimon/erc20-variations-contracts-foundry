// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

interface ISanctionRoles {

    // ----------- Events -----------

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event SanctionAdminSetStarted(address indexed previousSanctionAdmin, address indexed newSanctionAdmin);
    event SanctionAdminSet(address indexed previousSanctionAdmin, address indexed newSanctionAdmin);

    event MinterSet(address indexed previousMinter, address indexed newMinter);

    // ----------- Governor only state changing api -----------

    function transferOwnership(address newOwner) external;
    function setSanctionAdmin(address newSanctionAdmin) external;
    function setMinter(address newMinter) external;

    // ----------- State changing Api -----------

    function acceptOwnership() external;
    function acceptSanctionAdmin() external;

    // ----------- Getters -----------

    function owner() external view returns (address);
    function pendingOwner() external view returns (address);

    function sanctionAdmin() external view returns (address);
    function pendingSanctionAdmin() external view returns (address);

    function minter() external view returns (address);
}