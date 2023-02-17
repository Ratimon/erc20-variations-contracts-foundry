// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IGodRoles} from "@main/interfaces/IGodRoles.sol";
import {Errors} from "@main/shared/Error.sol";

/**
 * @notice Customised Ownable Contract, preventing setting wrong admin address
 * @dev more details is at https://docs.openzeppelin.com/contracts/4.x/api/access#Ownable2Step
 */
contract GodRoles is IGodRoles {

    // ----------- Events -----------

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event GodSetStarted(address indexed previousGod, address indexed newGod);
    event GodSet(address indexed previousGod, address indexed newGod);

    ///@notice the address of the current owner, that is able to set new god's address
    address internal _owner;
    ///@notice the pending address of the owner, that is able to set new god's address
    address internal _pendingOwner;

    ///@notice the address which is  is able to transfer tokens between addresses at will
    address internal _god;
    ///@notice the pending address which is  is able to transfer tokens between addresses at will
    address internal _pendingGod;

    /**
     * @notice GodRoles constructor
     * @param initialOwner initial owner
     * @param initialGod initial god
     */
    constructor(
        address initialOwner,
        address initialGod
    ) {
        if (initialOwner == address(0)) revert Errors.ZeroAddressNotAllowed();
        if (initialGod == address(0)) revert Errors.ZeroAddressNotAllowed();

        _owner = initialOwner;
        _god = initialGod;
        emit OwnershipTransferred(address(0), initialOwner);
        emit GodSet(address(0), initialGod);
    }

    /**
     * @notice Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external {
        if (_owner != msg.sender) revert Errors.NotAuthorized(msg.sender);

        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(_owner, newOwner);
    }

    /**
     * @notice The new owner accepts the ownership transfer.
     * Can only be called current owner.
     */
    function acceptOwnership() external {
        if (_pendingOwner != msg.sender) revert Errors.NotAuthorized(msg.sender);

        delete _pendingOwner;
        address oldOwner = _owner;
        _owner = msg.sender;
        emit OwnershipTransferred(oldOwner, _owner);
    }

    /**
     * @notice set the new God
     * Can only be called by ether owner or the current god.
     */
    function setGod(address newGod) external {
        if ( (_god != msg.sender) && (_owner != msg.sender) ) revert Errors.NotAuthorized(msg.sender);

        _pendingGod = newGod;
        emit GodSetStarted(_god, newGod);
    }

    /**
     * @notice The new God accepts the God ownership transfer.
     * Can only be called current god.
     */
    function acceptGod() external {
        if (_pendingGod != msg.sender) revert Errors.NotAuthorized(msg.sender);

        delete _pendingGod;
        address oldGod = _god;
        _god = msg.sender;
        emit GodSet(oldGod, _god);
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
     * @notice Get the god of the contract.
    **/
    function god() external view override returns (address){
        return _god;
    }

    /**
     * @notice Get the pending god of the contract.
    **/
    function pendingGod() external view override returns (address){
        return _pendingGod;
    }

}