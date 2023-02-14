// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {IERC1363Receiver} from "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";
import {IERC1363Spender} from "@openzeppelin/contracts/interfaces/IERC1363Spender.sol";

import {Errors} from "../shared/Error.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

/**
 * @title ERC1363PayableBase
 * @dev Implementation of a contract that wants to accept ERC1363 payments.
 */
contract ERC1363PayableBase is IERC1363Receiver, IERC1363Spender, ERC165{
    using ERC165Checker for address;

    /**
     * @dev Emitted when `amount` tokens are moved from one account (`sender`) to
     * this by spender (`operator`) using `transferAndCall` or `transferFromAndCall`.
     */
    event TokensReceived(address indexed operator, address indexed sender, uint256 amount, bytes data);

    /**
     * @dev Emitted when the allowance of this for a `sender` is set by
     * a call to `approveAndCall`. `amount` is the new allowance.
     */
    event TokensApproved(address indexed sender, uint256 amount, bytes data);

    
    ///@notice The ERC1363 token accepted
    IERC1363 private immutable  _acceptedToken;

    /**
     * @notice ERC1363PayableBase constructor
     * @param acceptedToken_ Address of the token being accepted
     */
    constructor(IERC1363 acceptedToken_) {

        if (address(acceptedToken_) == address(0)) revert Errors.ZeroAddressNotAllowed();
        if (!acceptedToken_.supportsInterface(type(IERC1363).interfaceId)) revert Errors.UnsupportedInterface();
        _acceptedToken = acceptedToken_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return
            interfaceId == type(IERC1363Receiver).interfaceId ||
            interfaceId == type(IERC1363Spender).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /*
     * @dev Note: remember that the token contract address is always the message sender.
     * @param spender The address which called `transferAndCall` or `transferFromAndCall` function
     * @param sender The address which are token transferred from
     * @param amount The amount of tokens transferred
     * @param data Additional data with no specified format
     */
    function onTransferReceived(
        address spender,
        address sender,
        uint256 amount,
        bytes memory data
    ) public override returns (bytes4) {
        require(msg.sender == address(_acceptedToken), "ERC1363Payable: acceptedToken is not message sender");

        emit TokensReceived(spender, sender, amount, data);

        _transferReceived(spender, sender, amount, data);

        return IERC1363Receiver.onTransferReceived.selector;
    }

    /*
     * @dev Note: remember that the token contract address is always the message sender.
     * @param sender The address which called `approveAndCall` function
     * @param amount The amount of tokens to be spent
     * @param data Additional data with no specified format
     */
    function onApprovalReceived(address sender, uint256 amount, bytes memory data) public override returns (bytes4) {
        require(msg.sender == address(_acceptedToken), "ERC1363Payable: acceptedToken is not message sender");

        emit TokensApproved(sender, amount, data);

        _approvalReceived(sender, amount, data);

        return IERC1363Spender.onApprovalReceived.selector;
    }

    /**
     * @dev The ERC1363 token accepted
     */
    function acceptedToken() public view returns (IERC1363) {
        return _acceptedToken;
    }

    /**
     * @dev Called after validating a `onTransferReceived`. Override this method to
     * make your stuffs within your contract.
     * @param spender The address which called `transferAndCall` or `transferFromAndCall` function
     * @param sender The address which are token transferred from
     * @param amount The amount of tokens transferred
     * @param data Additional data with no specified format
     */
    function _transferReceived(address spender, address sender, uint256 amount, bytes memory data) internal virtual {
        // optional override
    }

    /**
     * @dev Called after validating a `onApprovalReceived`. Override this method to
     * make your stuffs within your contract.
     * @param sender The address which called `approveAndCall` function
     * @param amount The amount of tokens to be spent
     * @param data Additional data with no specified format
     */
    function _approvalReceived(address sender, uint256 amount, bytes memory data) internal virtual {
        // optional override
    }


}