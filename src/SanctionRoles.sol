// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Errors} from "./shared/Error.sol";

/**
 * @notice Customised Access Conrol Contract, preventing setting wrong admin address
 * @dev more details is at https://docs.openzeppelin.com/contracts/4.x/api/access#Ownable2Step
 */
contract SanctionRoles {

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event SanctionAdminSetStarted(address indexed previousSanctionAdmin, address indexed newSanctionAdmin);
    event SanctionAdminSet(address indexed previousSanctionAdmin, address indexed newSanctionAdmin);

    ///@notice the address of the current owner, that is able to set new SanctionAdmin's address
    address internal owner;
    address internal pendingOwner;

    ///@notice the address which is able to ban specified addresses from sending and receiving tokens
    address internal sanctionAdmin;
    address internal pendingSanctionAdmin;


    /**
     * @notice SanctionRoles constructor
     * @param initialOwner initial owner
     * @param initialSanctionAdmin initial admin who is able to sanction
     */
    constructor(
        address initialOwner,
        address initialSanctionAdmin
    ) {
        if (initialOwner == address(0)) revert Errors.ZeroAddressNotAllowed();
        if (initialSanctionAdmin == address(0)) revert Errors.ZeroAddressNotAllowed();

        owner = initialOwner;
        sanctionAdmin = initialSanctionAdmin;
        emit OwnershipTransferred(address(0), initialOwner);
        emit SanctionAdminSet(address(0), initialSanctionAdmin);
    }

    /**
     * @notice Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external {
        if (owner != msg.sender) revert Errors.NotAuthorized(msg.sender);

        pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner, newOwner);
    }

    /**
     * @notice The new owner accepts the ownership transfer.
     */
    function acceptOwnership() external {
        if (pendingOwner != msg.sender) revert Errors.NotAuthorized(msg.sender);

        delete pendingOwner;
        address oldOwner = owner;
        owner = msg.sender;
        emit OwnershipTransferred(oldOwner, owner);
    }


    /**
     * @notice Starts the new SanctionAdmin  that is able to ban specified addresses from sending and receiving tokens
     * Can only be called by ether owner or the current sanctionAdmin admin.
     */
    function setSanctionAdmin(address newSanctionAdmin) external {

        if ( (sanctionAdmin != msg.sender) && (owner != msg.sender) ) revert Errors.NotAuthorized(msg.sender);

        pendingSanctionAdmin = newSanctionAdmin;
        emit SanctionAdminSetStarted(sanctionAdmin, newSanctionAdmin);
    }

    /**
     * @notice The new SanctionAdmin accepts the SanctionAdmin ownership transfer.
     */
    function acceptSanctionAdmin() external {
        if (pendingSanctionAdmin != msg.sender) revert Errors.NotAuthorized(msg.sender);

        delete pendingSanctionAdmin;
        address oldSanctionAdmin = sanctionAdmin;
        sanctionAdmin = msg.sender;
        emit SanctionAdminSet(oldSanctionAdmin, sanctionAdmin);
    }
}