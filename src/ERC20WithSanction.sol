// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Errors} from "./shared/Error.sol";
import {SanctionRoles} from "./SanctionRoles.sol";

/**
 * @notice ERC20 with sanctions. It allows an admin to ban specified addresses from sending and receiving tokens.
 */
contract ERC20WithSanction is ERC20, SanctionRoles {

    mapping (address => bool) isBlacklist;


    /**
     * @notice erc20 with sanction constructor
     * @param name token name for ERC20
     * @param symbol token symbol for ERC20
     */
    constructor(
        string memory name,
        string memory symbol,
        address  initialOwner,
        address  initialSanctionAdmin
        ) ERC20(name, symbol) SanctionRoles(initialOwner,initialSanctionAdmin) {


    }

    modifier onlyOwner() {
        if (_owner != msg.sender  ) revert Errors.NotAuthorized(msg.sender);
        _;
    }

    modifier onlySanctionAdmin() {
        if (_pendingSanctionAdmin != msg.sender  ) revert Errors.NotAuthorized(msg.sender);
        _;
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal virtual override
    {
        require(!isBlacklist[msg.sender], "The caller is on the blacklist");
        super._beforeTokenTransfer(from, to, amount);
    }


    /**
     * @notice add an address to sanction list
     * @param _blacklist account to be sanctioned
     */
    function addToBlackList(address _blacklist) external onlySanctionAdmin {
        isBlacklist[_blacklist] = true;
    }

        /**
     * @notice remove an address to sanction list
     * @param _blacklist account to be sanctioned
     */
    function removeFromBlacklist(address _blacklist) external onlySanctionAdmin {
        isBlacklist[_blacklist] = false;
    }




}