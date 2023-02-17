// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

interface ISanctionRoles {

    // ----------- Governor only state changing api -----------

    function setSanctionAdmin(address newSanctionAdmin) external;
    function setMinter(address newMinter) external;

    // ----------- State changing Api -----------

    function acceptSanctionAdmin() external;
    function acceptMinter() external;

    // ----------- Getters -----------

    function owner() external view returns (address);
    function pendingOwner() external view returns (address);

    function sanctionAdmin() external view returns (address);
    function pendingSanctionAdmin() external view returns (address);

    function minter() external view returns (address);
    function pendingMinter() external view returns (address);
}