// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";
import {console} from "@forge-std/console.sol";

import {MockERC20} from  "@solmate/test/utils/mocks/MockERC20.sol";
import {LinearBondingCurve} from "@main/LinearBondingCurve.sol";


contract InvariantOwner is Test {

    LinearBondingCurve internal  _bondingCurve;
    MockERC20 internal _underlyingBuyToken;
    MockERC20 internal _underlyingSaleToken;
    // address owner;
    uint256 public staticTime;


    mapping(bytes32 => uint256) public calls;

    modifier countCall(bytes32 key) {
        calls[key]++;
        _;
    }

    constructor(address bondingCurve_, address underlyingBuyToken_, address underlyingSaleToken_, uint256 staticTime_) {
        _bondingCurve    = LinearBondingCurve(bondingCurve_);
        _underlyingBuyToken = MockERC20(underlyingBuyToken_);
        _underlyingSaleToken =  MockERC20(underlyingSaleToken_);
        // owner = owner_;
        staticTime = staticTime_;
    }

    function allocate(uint256 amount_) external countCall("allocate") {
        // vm.startPrank(owner);
        // vm.assume(owner != to);

        vm.warp(staticTime + 3 weeks);
        // vm.warp(block.timestamp + bound(warpTime_, 2 weeks, 3 weeks));

        amount_ = bound(amount_, 0, _underlyingBuyToken.balanceOf(address(_bondingCurve)));
        uint256 startingBuyBalance = _underlyingBuyToken.balanceOf(address(this));
        // console.log('before  Allocate');
        _bondingCurve.allocate( amount_,  address(this));
        // console.log('After  Allocate');
        assertEq(_underlyingBuyToken.balanceOf(address(this)), startingBuyBalance + amount_);
        // vm.stopPrank();

    }

    function callSummary() external view {
        console.log("-------------------");
        console.log("allocate", calls["allocate"]);
    }


}