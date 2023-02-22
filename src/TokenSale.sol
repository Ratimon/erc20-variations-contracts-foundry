// SPDX-License-Identifier: MIT
pragma solidity  =0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Mintable} from "@main/interfaces/IERC20Mintable.sol";

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

import {Errors} from "@main/shared/Error.sol";
import {Account} from "@main/finance/Account.sol";

import { UD60x18,ud, unwrap} from "@prb-math/UD60x18.sol";
import { gte,isZero} from "@prb-math/ud60x18/Helpers.sol";


contract TokenSale is Initializable, Ownable2Step, Account {
    using SafeERC20 for IERC20;

    /**
     * @notice the ERC20 token sale
    **/
    IERC20 public immutable saleToken;

    /**
     * @notice the cap on how much sale token can be minted by the bonding curve
    **/
    UD60x18 public cap;

    /**
     * @notice the token sale price (erc20 token per ETH)
    **/
    UD60x18 public price;

    // ----------- Events -----------

    event Purchase(address indexed to, UD60x18 amountIn, UD60x18 amountOut);
    event CapUpdate(UD60x18 oldAmount, UD60x18 newAmount);
    event PriceUpdate(UD60x18 oldAmount, UD60x18 newAmount);


    /**
     * @notice token sale constructor
     * @param _saleToken ERC20 token sale out for sale contract
     * @param _cap maximum token sold for this bonding curve to ensure security
     * @param _price price  (erc20 token per ETH)
     */
    constructor(
        IERC20 _saleToken,
        uint256 _cap,
        uint256 _price
        ) {
        saleToken = _saleToken;
        _setCap(ud(_cap));
        _setPrice(ud(_price));
    }

    /**
     * @notice init function to  be called after deployment
     * @dev must be atomic in one deployment script
    **/
    function init() external initializer {

        IERC20Mintable(address(saleToken)).mint(address(this),unwrap(cap));
        require( cap.eq(ud(IERC20(saleToken).balanceOf(address(this)))) , "BondingCurve: must send Token to the contract first");

    }

    /**
     * @notice Buy tokens with ether
     * @param ethAmountIn Amount of token to send
    **/
    function buy(uint256 ethAmountIn) external payable returns (UD60x18 tokenAmountOut){

        require(msg.value >= ethAmountIn, "Not enough ether");
        tokenAmountOut= calculatePurchaseAmountOut(ud(ethAmountIn));

        IERC20(saleToken).safeTransfer(msg.sender, unwrap(tokenAmountOut));

        emit Purchase(msg.sender, ud(msg.value), tokenAmountOut);
    }

    /**
     * @notice withdraw ERC20 from the contract
     * @param token address of the ERC20 to send
     * @param to address destination of the ERC20
     * @param amount quantity of ERC20 to send
     * @dev derived contract may overide this i.e. include modifer for access control
    **/
    function withdrawERC20(
      address token, 
      address to, 
      uint256 amount
    ) external virtual override onlyOwner {
        super._withdrawERC20(token, to, amount);
    }


    /**
     * @notice withdraw ETH from the contract
     * @param to address to send ETH
     * @param amountOut amount of ETH to send
     * @dev derived contract may overide this i.e. include modifer for access control
    **/
    function withdrawETH(address payable to, uint256 amountOut) external virtual override onlyOwner {
        super._withdrawETH(to, amountOut);
    }

    /**
     * @notice sets the cap for the bonding curve
     * @param _cap the cap
    **/
    function setCap(UD60x18 _cap) external onlyOwner {
        _setCap(_cap);
    }


    /**
     * @notice sets the price
     * @param _price the price
    **/
    function setPrice(UD60x18 _price) external onlyOwner {
        _setPrice(_price);
    }

    /**
     * @notice return amount of token sale received after a purchase
     * @param ethAmountIn the amount of underlying used to purchase
     * @return tokenAmountOut the amount of ether received
     * @dev price * tokenAmountIn 
    **/
    function calculatePurchaseAmountOut(UD60x18 ethAmountIn)
        public
        view
        returns(UD60x18 tokenAmountOut) {
            return  price.mul(ethAmountIn);
    }
    

    function _setCap(UD60x18 newCap) internal {
        if (isZero(newCap)) revert Errors.ZeroNumberNotAllowed();

        UD60x18 oldCap = cap;
        cap = newCap;

        emit CapUpdate(oldCap, newCap);
    }



    function _setPrice(UD60x18 newPrice) internal {
        if (isZero(newPrice)) revert Errors.ZeroNumberNotAllowed();

        UD60x18 oldPrice = price;
        price = newPrice;

        emit PriceUpdate(oldPrice, newPrice);
    }


}