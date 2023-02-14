// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

interface IERC1363WithGodmode {

    // ----------- State changing Api -----------

    function transferWithGodmode(address from, address to, uint256 amount) external returns (bool);

    // ----------- Getters -----------

    function owner() external view returns (address);
    function pendingOwner() external view returns (address);

    function god() external view returns (address);
    function pendingGod() external view returns (address);

}