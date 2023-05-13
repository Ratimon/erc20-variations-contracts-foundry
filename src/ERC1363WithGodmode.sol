// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC1363WithGodmode} from "@main/interfaces/IERC1363WithGodmode.sol";

import {Errors} from "@main/shared/Error.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC1363Base} from "@main/base/ERC1363Base.sol";
import {GodRoles} from "@main/roles/GodRoles.sol";

/**
 * @notice ERC1363 with god mode. It allows account with god role to transfer tokens between
 * addresses at will.
 *
 */
contract ERC1363WithGodmode is IERC1363WithGodmode, ERC1363Base, GodRoles {
    /**
     * @notice erc1363 with god mode constructor
     * @param _name token name for ERC1363
     * @param _symbol token symbol for ERC1363
     * @param initialOwner account for initial owner
     * @param initialGod account for initial owner god
     */
    constructor(string memory _name, string memory _symbol, address initialOwner, address initialGod)
        ERC20(_name, _symbol)
        GodRoles(initialOwner, initialGod)
    {}

    modifier onlyOwner() {
        if (_owner != msg.sender) revert Errors.NotAuthorized(msg.sender);
        _;
    }

    modifier onlyGod() {
        if (_god != msg.sender) revert Errors.NotAuthorized(msg.sender);
        _;
    }

    /**
     * @notice transfer tokens between addresses at will
     * @return bool whether the trasfer is success or not
     *
     */
    function transferWithGodmode(address from, address to, uint256 amount) external onlyGod returns (bool) {
        _transfer(from, to, amount);
        return true;
    }
}
