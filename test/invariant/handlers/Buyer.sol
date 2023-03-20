// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;


import {Test} from "@forge-std/Test.sol";
import {console} from "@forge-std/console.sol";
import {UD60x18, ud, unwrap } from "@prb-math/UD60x18.sol";


import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {MockERC20} from  "@solmate/test/utils/mocks/MockERC20.sol";
import {LinearBondingCurve} from "@main/LinearBondingCurve.sol";


contract InvariantBuyer is Test {

    LinearBondingCurve internal  _bondingCurve;
    MockERC20 internal _underlyingBuyToken;
    MockERC20 internal _underlyingSaleToken;

    constructor(address bondingCurve_, address underlyingBuyToken_, address underlyingSaleToken_) {
        _bondingCurve    = LinearBondingCurve(bondingCurve_);
        _underlyingBuyToken = MockERC20(underlyingBuyToken_);
        _underlyingSaleToken =  MockERC20(underlyingSaleToken_);
    }

    function purchase(uint256 amount_) external {

        amount_ = bound(amount_, 1, 30e18 );  

        uint256 startingBuyBalance = _underlyingBuyToken.balanceOf(address(this));
        uint256 startingSaleBalance = _underlyingSaleToken.balanceOf(address(this));
        uint256 saleAmountOut =  unwrap (_bondingCurve.calculatePurchaseAmountOut( ud(amount_)) );

        _underlyingBuyToken.mint(address(this), amount_);
        _underlyingBuyToken.approve(address(_bondingCurve), amount_);

        _bondingCurve.purchase( address(this),  amount_);

        // Ensure successful purchase
        assertEq(_underlyingBuyToken.balanceOf(address(this)), startingBuyBalance - amount_);
        assertEq(_underlyingSaleToken.balanceOf(address(this)), startingSaleBalance + saleAmountOut);  

    }

}


contract InvariantBuyerManager is Test {

    address  _bondingCurve;
    address internal _underlyingBuyToken;
    address internal _underlyingSaleToken;

    InvariantBuyer[] public buyers;

    constructor(address bondingCurve_, address underlyingBuyToken_, address underlyingSaleToken_) {
        _bondingCurve    = bondingCurve_;
        _underlyingBuyToken = underlyingBuyToken_;
        _underlyingSaleToken =  underlyingSaleToken_;
    }

    function createBuyer() external {
        InvariantBuyer buyer = new InvariantBuyer(_bondingCurve, _underlyingBuyToken, _underlyingSaleToken);
        buyers.push(buyer);
    }

    function purchase(uint256 amount_, uint256 index_) external {

        index_ = bound(index_, 0, buyers.length - 1 );  

        buyers[index_].purchase(amount_);

    }

    function getBuyerCount() external view returns (uint256 stakerCount_) {
        return buyers.length;
    }

}