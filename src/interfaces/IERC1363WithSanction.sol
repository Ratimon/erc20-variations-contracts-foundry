// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

interface IERC1363WithSanction {

    // ----------- Events -----------

    event BlackListAdded(address indexed blacklist);
    event BlackListRemoved(address indexed blacklist);

    // ----------- State changing Api -----------

    function mint(address to, uint256 amount) external;

    // ----------- Governor only state changing api -----------

    function addToBlackList(address _blacklist) external ;
    function removeFromBlacklist(address _blacklist) external;

    // ----------- Getters -----------
    
    function isBlacklist(address blacklist) external returns (bool);

}