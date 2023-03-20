// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Mintable} from "@main/interfaces/IERC20Mintable.sol";
import {IERC1363WithSanction} from "@main/interfaces/IERC1363WithSanction.sol";
import {ISanctionRoles} from "@main/interfaces/ISanctionRoles.sol";

import {ERC1363WithSanction} from "@main/ERC1363WithSanction.sol";
import {TokenSale} from "@main/TokenSale.sol";

import {UD60x18,ud, unwrap } from "@prb-math/UD60x18.sol";

import {ConstantsFixture}  from "@test/unit/utils/ConstantsFixture.sol";
import {DeploymentERC1363WithSanction}  from "@test/unit/utils/ERC1363WithSanction.constructor.sol";
import {DeploymentTokenSale}  from "@test/unit/utils/TokenSale.constructor.sol";

contract TestUnitTokenSale is  ConstantsFixture, DeploymentERC1363WithSanction, DeploymentTokenSale{

    IERC1363WithSanction erc1363WithSanction;
    TokenSale tokenSaleContract;

    function setUpScripts() internal virtual override {
        SCRIPTS_BYPASS = true; // deploys contracts without any checks whatsoever
    }

    function setUp() public virtual override {
         super.setUp();
        vm.label(address(this), "TestUnitTokenSale");

        vm.startPrank(deployer);

        arg_erc1363WithSanction.name = "Test Sanction Token";
        arg_erc1363WithSanction.symbol = "SANC";
        arg_erc1363WithSanction.initialOwner = msg.sender;
        arg_erc1363WithSanction.initialSanctionAdmin = msg.sender;
        arg_erc1363WithSanction.initialMinter = msg.sender;

        erc1363WithSanction = new ERC1363WithSanction(
            arg_erc1363WithSanction.name,
            arg_erc1363WithSanction.symbol,
            arg_erc1363WithSanction.initialOwner,
            arg_erc1363WithSanction.initialSanctionAdmin,
            arg_erc1363WithSanction.initialMinter
        );
        vm.label(address(erc1363WithSanction), "erc1363WithSanction");

        arg_tokenSale.token = IERC20(address(erc1363WithSanction));
        arg_tokenSale._cap =  1_000e18;
        arg_tokenSale._price = 20e18;

        tokenSaleContract = new TokenSale(
            arg_tokenSale.token,
            arg_tokenSale._cap,
            arg_tokenSale._price
        );
            
        vm.label(address(tokenSaleContract), "tokenSaleContract");

        IERC20Mintable(address(erc1363WithSanction)).mint(deployer,arg_tokenSale._cap );
        IERC20(address(erc1363WithSanction)).approve(address(tokenSaleContract),maxUint256);
        ISanctionRoles(address(erc1363WithSanction)).setMinter(address(tokenSaleContract));

        tokenSaleContract.init();

        vm.stopPrank();
    }

    function test_Constructor() public {
        assertEq( unwrap(tokenSaleContract.cap()), IERC20(address(erc1363WithSanction)).balanceOf(address(tokenSaleContract)) );
    }

    function test_buy() public {
        deal(alice, 200 ether);

        vm.startPrank(alice);

        uint256 alicePreBalBuyingToken = IERC20(address(erc1363WithSanction)).balanceOf(alice);
        uint256 contractPreBalBuyingToken = IERC20(address(erc1363WithSanction)).balanceOf(address(tokenSaleContract));

        assertEq(alicePreBalBuyingToken, 0e18 );
        assertEq(contractPreBalBuyingToken, 1000e18 );

        uint256 buy_amount = 10e18;

        UD60x18 tokenAmountOut = ud(buy_amount).mul(ud(arg_tokenSale._price));

        tokenSaleContract.buy{value: buy_amount}(buy_amount);

        uint256 alicePostBalBuyingToken = IERC20(address(erc1363WithSanction)).balanceOf(alice);
        uint256 contractPostBalBuyingToken = IERC20(address(erc1363WithSanction)).balanceOf(address(tokenSaleContract));

        uint256 changeInAliceBalBuyingToken = alicePostBalBuyingToken > alicePreBalBuyingToken ? (alicePostBalBuyingToken - alicePreBalBuyingToken) : (alicePreBalBuyingToken - alicePostBalBuyingToken);
        uint256 changeInContractBalBuyingToken = contractPostBalBuyingToken > contractPreBalBuyingToken ? (contractPostBalBuyingToken - contractPreBalBuyingToken) : (contractPreBalBuyingToken - contractPostBalBuyingToken);


        assertEq(unwrap(tokenAmountOut) , changeInAliceBalBuyingToken);
        assertEq(unwrap(tokenAmountOut) , changeInContractBalBuyingToken);

        assertEq(alicePostBalBuyingToken, 200e18 );
        assertEq(contractPostBalBuyingToken, 800e18 );


        vm.stopPrank();
    }


}