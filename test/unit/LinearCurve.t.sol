// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Test} from "@forge-std/Test.sol";
import {StdUtils} from "@forge-std/StdUtils.sol";

import { Assertions as PRBMathAssertions } from "@prb-math/test/Assertions.sol";
import { powu } from "@prb-math/ud60x18/Math.sol";
import { UD60x18, ud } from "@prb-math/UD60x18.sol";

import {MockLinearCurve} from "@main/mocks/MockLinearCurve.sol";
import {ConstantsFixture}  from "@test/unit/utils/ConstantsFixture.sol";

contract TestUnitLinearCurve is StdUtils, PRBMathAssertions, ConstantsFixture {

    uint256 immutable SLOPE = 1.5e18;
    uint256 immutable INTITIAL_PRICE = 30e18;

    MockLinearCurve linearCurveContract;

    function setUp() public {
        vm.label(address(this), "TestUnitLinearCurve");

        deployer = msg.sender;
        vm.label(deployer, "Deployer");

        vm.startPrank(deployer);

        linearCurveContract = new MockLinearCurve(SLOPE, INTITIAL_PRICE);
        vm.label(address(linearCurveContract), "linearCurveContract");

        vm.stopPrank();

    }

    function test_getInstantaneousPrice() external {
        UD60x18 tokenAmountIn = ud(20e18);

        UD60x18 actualPrice = linearCurveContract.getLinearInstantaneousPrice(tokenAmountIn);
        UD60x18 expectedPrice = ud(60e18);
        // 1.5*20 + 30 = 60
        assertEq(actualPrice, expectedPrice);
    }

    function testFuzz_getInstantaneousPrice(uint256 tokenSupply) external {
        tokenSupply = bound( tokenSupply, 0.5e18, 200e18);
        UD60x18 tokenAmountIn = ud(tokenSupply);

        UD60x18 actualPrice = linearCurveContract.getLinearInstantaneousPrice(tokenAmountIn);
        UD60x18 expectedPrice = ud(SLOPE).mul(tokenAmountIn).add(ud(INTITIAL_PRICE));

        assertEq(actualPrice, expectedPrice);
    }

    function test_getPoolBalance() external {
        UD60x18 tokenAmountIn = ud(20e18);

        UD60x18 actualBalance = linearCurveContract.getPoolBalance(tokenAmountIn);
        UD60x18 expectedBalance = ud(900e18);

        // 1.5/2*(20^2) + 30*(20) = 900
        assertEq(actualBalance, expectedBalance);
    }

    function testFuzz_getPoolBalance(uint256 tokenSupply) external {
        tokenSupply = bound( tokenSupply, 0.5e18, 200e18);
        UD60x18 tokenAmountIn = ud(tokenSupply);

        UD60x18 actualBalance = linearCurveContract.getPoolBalance(tokenAmountIn);
        UD60x18 expectedBalance = ud(SLOPE).mul(powu(tokenAmountIn,2)).div(ud(2e18)).add(tokenAmountIn.mul(ud(INTITIAL_PRICE)));

        assertEq(actualBalance, expectedBalance);
    }

    function test_getTokenSupply() external {
        UD60x18 balanceAmountIn = ud(900e18);

        UD60x18 actualTokenAmount = linearCurveContract.getTokenSupply(balanceAmountIn);
        UD60x18 expectedTokenAmount = ud(20e18);

        // 1.5/2*(20^2) + 30*(20) = 900
        // f-1(y) = (-b + sqrt(b^2 + 2my)) / m
        // f-1(900) = (-30 + sqrt(30^2 + 2(1.5)*900)) / 1.5 = 20
         
        assertEq(actualTokenAmount, expectedTokenAmount);
    }

}