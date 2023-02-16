// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Test} from "@forge-std/Test.sol";
import { Assertions as PRBMathAssertions } from "@prb-math/test/Assertions.sol";
import { UD60x18, ud } from "@prb-math/UD60x18.sol";
// import {PRBTest } from "@prb-test/PRBTest.sol";


import {MockLinearCurve} from "@main/mocks/MockLinearCurve.sol";

contract TestLinearCurve is PRBMathAssertions {

// contract TestLinearCurve is PRBTest, PRBMathAssertions {

    uint256 immutable SLOPE = 1.5e18;
    uint256 immutable INTITIAL_PRICE = 30e18;

    MockLinearCurve LinearCurveContract;


    function setUp() public {
        LinearCurveContract = new MockLinearCurve(SLOPE, INTITIAL_PRICE);
    }

    function test_getInstantaneousPrice() external {

        UD60x18 tokenAmountIn = ud(20e18);

        UD60x18 actualPrice = LinearCurveContract.getInstantaneousPrice(tokenAmountIn);
        UD60x18 expectedPrice = ud(60e18);
        
        //20*1.5+30 = 60
        assertEq(actualPrice, expectedPrice);

    }

}