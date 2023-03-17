// // SPDX-License-Identifier: MIT
// pragma solidity =0.8.17;

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import {CommonBase} from "@forge-std/Base.sol";
// import {StdCheats} from "@forge-std/StdCheats.sol";
// import {StdUtils} from "@forge-std/StdUtils.sol";
// import {console} from "@forge-std/console.sol";

// import {IBondingCurve} from "@main/interfaces/IBondingCurve.sol";
// import {IERC1363WithSanction} from "@main/interfaces/IERC1363WithSanction.sol";

// import {ERC1363WithSanction} from "@main/ERC1363WithSanction.sol";
// import {LinearBondingCurve} from "@main/LinearBondingCurve.sol";


// contract Handler is CommonBase, StdCheats, StdUtils {

//     LinearBondingCurve linearBondingCurve;

//     mapping(bytes32 => uint256) public calls;

//     AddressSet internal _actors;
//     address internal currentActor;

//     modifier createActor() {
//         currentActor = msg.sender;
//         _actors.add(msg.sender);
//         _;
//     }

//     modifier useActor(uint256 actorIndexSeed) {
//         currentActor = _actors.rand(actorIndexSeed);
//         _;
//     }

//     modifier countCall(bytes32 key) {
//         calls[key]++;
//         _;
//     }

//     constructor(LinearBondingCurve _linearBondingCurve) {
//         _linearBondingCurve = _linearBondingCurve;
//         deal(address(this), 1 ether);
//     }


//     function callSummary() external view {
//         console.log("Call summary:");
//         console.log("-------------------");
//         console.log("swapFromToken2To1", calls["swapFromToken2To1"]);
//         console.log("swapFromToken1To2", calls["swapFromToken1To2"]);
//     }

//     receive() external payable {}
// }