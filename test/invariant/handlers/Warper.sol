// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {CommonBase} from "@forge-std/Base.sol";
import {StdCheats} from "@forge-std/StdCheats.sol";
import {StdUtils} from "@forge-std/StdUtils.sol";
import {console} from "@forge-std/console.sol";

import {MockERC20} from  "@solmate/test/utils/mocks/MockERC20.sol";
import {LinearBondingCurve} from "@main/LinearBondingCurve.sol";


contract Warper is CommonBase, StdCheats, StdUtils {

    LinearBondingCurve internal  _bondingCurve;


    constructor(address bondingCurve_) {
        _bondingCurve    = LinearBondingCurve(bondingCurve_);
    }

    function warp(uint256 warpTime_) external {
        vm.warp(block.timestamp + bound(warpTime_, 3 weeks, 4 weeks));
    }

}