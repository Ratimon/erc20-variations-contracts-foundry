// SPDX-License-Identifier: MIT
pragma solidity  =0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {IBondingCurve} from "@main/interfaces/IBondingCurve.sol";
import {IERC20Mintable} from "@main/interfaces/IERC20Mintable.sol";

import {Errors} from "@main/shared/Error.sol";
import {ERC1363PayableBase} from "@main/base/ERC1363PayableBase.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

abstract contract BondingCurve is IBondingCurve, ERC1363PayableBase, Pausable, Ownable2Step {
    /**
     * @notice the ERC20 token sale for this bonding curve
    **/
    IERC20 public override immutable token;

    /**
     * @notice the total amount of token purchased on bonding curve
    **/
    uint256 public override totalPurchased;

    /**
     * @notice the cap on how much sale token can be minted by the bonding curve
    **/
    uint256 public override mintCap;

    /**
     * @notice BondingCurve constructor
     * @param _acceptedToken ERC20 token in for this bonding curve
     * @param _token ERC20 token sale out for this bonding curve
    **/
    constructor(
        IERC1363 _acceptedToken,
        IERC20 _token,
        uint256 _mintCap
        ) ERC1363PayableBase(_acceptedToken){
        token = _token;
        _setMintCap(_mintCap);
    }


    /// @notice purchase token for accepted tokens
    /// @param to address to sale token
    /// @param amountIn amount of underlying accepted tokens input
    /// @return amountOut amount of token sale received
    function purchase(address to, uint256 amountIn)
        external
        payable
        virtual
        override
        whenNotPaused
        returns (uint256 amountOut)
    {
        require(msg.value == 0, "BondingCurve: unexpected ETH input");
        acceptedToken().transferFromAndCall(msg.sender, to, amountIn);

        amountOut = _purchase(msg.sender, to, amountIn);
        return amountOut;
    }

    /**
     * @notice allocate held accepted ERC20 token
     * @param amount the amount quantity of underlying token  to allocate
     * @param to address destination
    **/
    function allocate(uint256 amount, address to) external onlyOwner {
        SafeERC20.safeTransfer(acceptedToken(), to, amount);
        emit Allocate(msg.sender, amount);
    }

    /**
     * @notice pause pausable function
    **/
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice unpause pausable function
    **/
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice resets the totalPurchased
    **/
    function reset() external override onlyOwner {
        uint256 oldTotalPurchased = totalPurchased;
        totalPurchased = 0;
        emit Reset(oldTotalPurchased);
    }

    /**
     * @notice sets the mint cap for the bonding curve
     * @param _mintCap the cap
    **/
    function setMintCap(uint256 _mintCap) external override onlyOwner {
        _setMintCap(_mintCap);
    }


    /**
     * @notice returns how close to the minting cap we are
    **/
    function availableToMint() public view override returns (uint256) {
        return mintCap - totalPurchased;
    }

    /**
     * @notice return current instantaneous bonding curve price
     * @return amountOut price reported 
     * @dev just use only one helper function from LinearCurve
    **/
    function getCurrentPrice() external view returns (uint256){
        return 1;
    }

    /**
     * @notice return amount of token received after a bonding curve purchase
     * @param amountIn the amount of underlying used to purchase
     * @return amountOut the amount of token received
    **/
    function getAmountOut(uint256 amountIn)
        public
        view
        returns (uint256 amountOut) {
            return 1;
    }

    /**
     * @notice balance of accepted token the bonding curve
     * @return the amount of accepted token held in contract and ready to be allocated
    **/
    function reserveBalance() public view virtual override returns (uint256) {
        return acceptedToken().balanceOf(address(this));
    }

    /**
     * @dev This method is called after `onTransferReceived`.
     *  Note: remember that the token contract address is always the message sender.
     * @param operator The address which called `transferAndCall` or `transferFromAndCall` function
     * @param sender Address performing the token purchase
     * @param amount The amount of tokens transferred
     * @param data Additional data with no specified format
     */
    function _transferReceived(address operator, address sender, uint256 amount, bytes memory data) internal override {
        _purchase(operator, sender, amount);
    }

    /**
     * @dev This method is called after `onApprovalReceived`.
     *  Note: remember that the token contract address is always the message sender.
     * @param sender address The address which called `approveAndCall` function
     * @param amount uint256 The amount of tokens to be spent
     * @param data bytes Additional data with no specified format
     */
    function _approvalReceived(address sender, uint256 amount, bytes memory data) internal override {
        IERC20(acceptedToken()).transferFrom(sender, address(this), amount);
        _purchase(sender, sender, amount);
    }

    function _purchase(address operator,  address to, uint256 amountIn)
        internal
        returns (uint256 amountOut)
    {
        amountOut = getAmountOut(amountIn);
        require(availableToMint() >= amountOut, "BondingCurve: exceeds mint cap");

        _incrementTotalPurchased(amountOut);
        IERC20Mintable(address(token)).mint(to, amountOut);

        emit Purchase(operator,to, amountIn, amountOut);
        return amountOut;
    }

    function _incrementTotalPurchased(uint256 amount) internal {
        totalPurchased = totalPurchased + amount;
    }

    function _setMintCap(uint256 newMintCap) internal {
        require(newMintCap != 0, "BondingCurve: zero mint cap");

        uint256 oldMintCap = mintCap;
        mintCap = newMintCap;

        emit MintCapUpdate(oldMintCap, newMintCap);
    }

}