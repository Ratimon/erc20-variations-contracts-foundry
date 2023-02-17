// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

interface IERC1363WithSanction {

    // ----------- Events -----------

    event BlackListAdded(address indexed blacklist);
    event BlackListRemoved(address indexed blacklist);

    // ----------- Governor only state changing api -----------

    function addToBlackList(address _blacklist) external ;
    function removeFromBlacklist(address _blacklist) external;

    // ----------- Getters -----------

    function owner() external view returns (address);
    function pendingOwner() external view returns (address);

    function sanctionAdmin() external view returns (address);
    function pendingSanctionAdmin() external view returns (address);

    function isBlacklist(address blacklist) external returns (bool);

}