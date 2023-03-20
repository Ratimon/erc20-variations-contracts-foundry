// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;


import {CommonBase} from "@forge-std/Base.sol";
import {StdCheats} from "@forge-std/StdCheats.sol";
import {StdUtils} from "@forge-std/StdUtils.sol";
import {console} from "@forge-std/console.sol";

import {MockERC20} from  "@solmate/test/utils/mocks/MockERC20.sol";
import {LinearBondingCurve} from "@main/LinearBondingCurve.sol";


contract InvariantOwner is CommonBase, StdCheats, StdUtils {


    LinearBondingCurve   bondingCurve;
    MockERC20 underlyingBuyToken;
    MockERC20 underlyingSaleToken;

    constructor(address bondingCurve_, address underlyingBuyToken_, address underlyingSaleToken_) {
        bondingCurve    = LinearBondingCurve(bondingCurve_);
        underlyingBuyToken = MockERC20(underlyingBuyToken_);
        underlyingSaleToken =  MockERC20(underlyingSaleToken_);
    }


}