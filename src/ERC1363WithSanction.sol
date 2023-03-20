// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC1363WithSanction} from "@main/interfaces/IERC1363WithSanction.sol";

import {Errors} from "@main/shared/Error.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC1363Base} from "@main/base/ERC1363Base.sol";
import {SanctionRoles} from "@main/roles/SanctionRoles.sol";


/**
 * @notice ERC1363 with sanctions. It allows an admin to ban specified addresses from sending and receiving tokens.
 */
contract ERC1363WithSanction is IERC1363WithSanction, ERC1363Base, SanctionRoles {

    /**
     * @notice the blacklist
    **/
    mapping (address => bool) public isBlacklist;

    /**
     * @notice erc1363 with sanction constructor
     * @param _name token name for ERC1363
     * @param _symbol token symbol for ERC1363
     * @param initialOwner account for initial owner 
     * @param initialSanctionAdmin account for initial sanctionAdmin
     * @param initialMinter account for initial minter eg. bonding curve or sale contract
    **/
    constructor(
        string memory _name,
        string memory _symbol,
        address  initialOwner,
        address  initialSanctionAdmin,
        address  initialMinter
        ) ERC20(_name, _symbol) SanctionRoles(initialOwner,initialSanctionAdmin, initialMinter)  {

    }

    modifier onlyOwner() {
        if (_owner != msg.sender) revert Errors.NotAuthorized(msg.sender);
        _;
    }

    modifier onlySanctionAdmin() {
        if (_sanctionAdmin != msg.sender) revert Errors.NotAuthorized(msg.sender);
        _;
    }

    modifier onlyMinter() {
        if (_minter != msg.sender) revert Errors.NotAuthorized(msg.sender);
        _;
    }

    /**
     * @notice mint new ERC1363 from the contract
     * @param to account to the ERC1363 to send
     * @param amount amount quantity of ERC1363 to send
     */
    function mint(address to, uint256 amount) external onlyMinter {
        _mint(to, amount);
    }

    /**
     * @notice add an address to sanction list
     * @param _blacklist account to be sanctioned
     */
    function addToBlackList(address _blacklist) external onlySanctionAdmin {
        isBlacklist[_blacklist] = true;
        emit BlackListAdded(_blacklist);
    }

    /**
     * @notice remove an address to sanction list
     * @param _blacklist account to be sanctioned
     */
    function removeFromBlacklist(address _blacklist) external onlySanctionAdmin {
        isBlacklist[_blacklist] = false;
        emit BlackListRemoved(_blacklist);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal virtual override
    {
        require(!isBlacklist[msg.sender], "The caller is on the blacklist");
        super._beforeTokenTransfer(from, to, amount);
    }

}


