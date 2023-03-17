// // SPDX-License-Identifier: MIT
// pragma solidity =0.8.17;

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
// import {IBondingCurve} from "@main/interfaces/IBondingCurve.sol";
// import {IERC1363WithSanction} from "@main/interfaces/IERC1363WithSanction.sol";

// import {Test} from "@forge-std/Test.sol";
// import {InvariantTest} from "@forge-std/InvariantTest.sol";

// import {ERC1363WithSanction} from "@main/ERC1363WithSanction.sol";
// import {LinearBondingCurve} from "@main/LinearBondingCurve.sol";

// import {MockERC20} from  "@solmate/test/utils/mocks/MockERC20.sol";
// import {UD60x18, ud, unwrap } from "@prb-math/UD60x18.sol";

// import {ConstantsFixture}  from "@test/unit/utils/ConstantsFixture.sol";
// import {DeploymentERC1363WithSanction}  from "@test/unit/utils/ERC1363WithSanction.constructor.sol";
// import {DeploymentLinearBondingCurve}  from "@test/unit/utils/LinearBondingCurve.constructor.sol";


// import {Handler} from "./handlers/Handler.sol";


// contract LinearBondingCurveInvariants is InvariantTest, ConstantsFixture, DeploymentERC1363WithSanction, DeploymentLinearBondingCurve  {
//     IERC1363WithSanction erc1363WithSanction;
//     IBondingCurve linearBondingCurve;

//     MockERC20 mockToken;
//     IERC20 saleToken;

//     Handler public handler;


//     function setUp() public {
//         vm.label(address(this), "LinearBondingCurveInvariants");

//         vm.startPrank(deployer);

//         arg_erc1363WithSanction.name = "Test Sanction Token";
//         arg_erc1363WithSanction.symbol = "SANC";
//         arg_erc1363WithSanction.initialOwner = msg.sender;
//         arg_erc1363WithSanction.initialSanctionAdmin = msg.sender;
//         arg_erc1363WithSanction.initialMinter = msg.sender;

//         erc1363WithSanction = new ERC1363WithSanction(
//             arg_erc1363WithSanction.name,
//             arg_erc1363WithSanction.symbol,
//             arg_erc1363WithSanction.initialOwner,
//             arg_erc1363WithSanction.initialSanctionAdmin,
//             arg_erc1363WithSanction.initialMinter
//         );
//          vm.label(address(erc1363WithSanction), "erc1363WithSanction");

//         mockToken = new MockERC20("TestSaleToken", "TT0", 18);
//         saleToken = IERC20(address(mockToken));
//         vm.label(address(saleToken), "TestSaleToken");

//         arg_linearBondingCurve.acceptedToken = IERC1363(address(erc1363WithSanction));
//         arg_linearBondingCurve.token = IERC20(address(saleToken));
//         arg_linearBondingCurve._cap = 1_000_000e18;
//         arg_linearBondingCurve._slope = 1.5e18;
//         arg_linearBondingCurve._initialPrice = 30e18;
        
//         linearBondingCurve = new LinearBondingCurve(
//             arg_linearBondingCurve.acceptedToken,
//             arg_linearBondingCurve.token, 
//             arg_linearBondingCurve._cap,
//             arg_linearBondingCurve._slope,
//             arg_linearBondingCurve._initialPrice
//         );

//         vm.label(address(linearBondingCurve), "linearBondingCurve");

//         IERC20(saleToken).approve(address(linearBondingCurve),maxUint256);
//         deal({token : address(saleToken), to: deployer, give: arg_linearBondingCurve._cap });
//         linearBondingCurve.init();

//         vm.stopPrank();

//         handler = new Handler(dex, alice);
//         vm.label(address(handler), "Handler");

//         // bytes4[] memory selectors = new bytes4[](1);

//         // selectors[0] = Handler.exploit.selector;

//         // targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));
//         // targetContract(address(handler));
//     }

//     function test_Constructor() public {
//         assertEq( unwrap(linearBondingCurve.cap()), IERC20(saleToken).balanceOf(address(linearBondingCurve)) );
//     }



// }