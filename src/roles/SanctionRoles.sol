// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ISanctionRoles} from "@main/interfaces/ISanctionRoles.sol";
import {Errors} from "@main/shared/Error.sol";

/**
 * @notice Customised 2-step Ownable Contract, preventing setting wrong admin address
 * @dev more details is at https://docs.openzeppelin.com/contracts/4.x/api/access#Ownable2Step
**/
contract SanctionRoles is ISanctionRoles{

    /**
     * @notice the address of the current owner, that is able to set new Sanction admin and minter
    **/  
    address internal _owner;
    address internal _pendingOwner;

    /**
     * @notice the address which is able to ban specified addresses from sending and receiving tokens
    **/    
    address internal _sanctionAdmin;
    address internal _pendingSanctionAdmin;

    /**
     * @notice the address which is able to mint tokens eg. bonding curve contracr
    **/
    address internal _minter;

    /**
     * @notice SanctionRoles constructor
     * @param initialOwner initial owner
     * @param initialSanctionAdmin initial admin who is able to sanction
    **/
    constructor(
        address initialOwner,
        address initialSanctionAdmin,
        address initialMinter
    ) {
        if (initialOwner == address(0)) revert Errors.ZeroAddressNotAllowed();
        if (initialSanctionAdmin == address(0)) revert Errors.ZeroAddressNotAllowed();
        if (initialMinter == address(0)) revert Errors.ZeroAddressNotAllowed();

        _owner = initialOwner;
        _sanctionAdmin = initialSanctionAdmin;
        _minter = initialMinter;
        emit OwnershipTransferred(address(0), initialOwner);
        emit SanctionAdminSet(address(0), initialSanctionAdmin);
        emit MinterSet(address(0), initialMinter);
    }

    /**
     * @notice Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
    **/
    function transferOwnership(address newOwner) external {
        if (_owner != msg.sender) revert Errors.NotAuthorized(msg.sender);

        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(_owner, newOwner);
    }

    /**
     * @notice The new owner accepts the ownership transfer.
     * Can only be called current owner.
    **/
    function acceptOwnership() external {
        if (_pendingOwner != msg.sender) revert Errors.NotAuthorized(msg.sender);

        delete _pendingOwner;
        address oldOwner = _owner;
        _owner = msg.sender;
        emit OwnershipTransferred(oldOwner, _owner);
    }


    /**
     * @notice set the new SanctionAdmin
     * Can only be called by either owner or the current sanctionAdmin admin.
    **/
    function setSanctionAdmin(address newSanctionAdmin) external {
        if ( (_sanctionAdmin != msg.sender) && (_owner != msg.sender) ) revert Errors.NotAuthorized(msg.sender);

        _pendingSanctionAdmin = newSanctionAdmin;
        emit SanctionAdminSetStarted(_sanctionAdmin, newSanctionAdmin);
    }

    /**
     * @notice The new SanctionAdmin accepts the SanctionAdmin ownership transfer.
     * Can only be called current sanctionAdmin admin.
    **/
    function acceptSanctionAdmin() external {
        if (_pendingSanctionAdmin != msg.sender) revert Errors.NotAuthorized(msg.sender);

        delete _pendingSanctionAdmin;
        address oldSanctionAdmin = _sanctionAdmin;
        _sanctionAdmin = msg.sender;
        emit SanctionAdminSet(oldSanctionAdmin, _sanctionAdmin);
    }

    /**
     * @notice set the new minter
     * Can only be called by either owner or the current minter.
    **/
    function setMinter(address newMinter) external {
        if ( (_minter != msg.sender) && (_owner != msg.sender) ) revert Errors.NotAuthorized(msg.sender);

        _minter = newMinter;
        emit MinterSet(_minter, newMinter);
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

    /**
     * @notice Get the minter of the contract.
    **/
    function minter() external view override returns (address){
        return _minter;
    }

}