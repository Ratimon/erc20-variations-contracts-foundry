// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

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
     * @param name token name for ERC1363
     * @param symbol token symbol for ERC1363
     * @param initialOwner account for initial owner 
     * @param initialSanctionAdmin account for initial sanctionAdmin
    **/
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
        if (_sanctionAdmin != msg.sender  ) revert Errors.NotAuthorized(msg.sender);
        _;
    }

    /**
     * @notice Get the owner of the contract.
    **/
    function owner() external view override returns (address) {
        return _owner;
    }

    /**
     * @notice Get the pending owner of the contract.
    **/
    function pendingOwner() external view override returns (address){
        return _pendingOwner;
    }

    /**
     * @notice Get the sanction admin of the contract.
    **/
    function sanctionAdmin() external view override returns (address){
        return _sanctionAdmin;
    }

    /**
     * @notice Get the pending sanction admin of the contract.
    **/
    function pendingSanctionAdmin() external view override returns (address){
        return _pendingSanctionAdmin;
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

}


