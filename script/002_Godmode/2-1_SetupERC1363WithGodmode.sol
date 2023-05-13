// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";
import {RegisterScripts} from "../RegisterScripts.sol";

import {Constants} from "../Constants.sol";
import {IERC1363WithGodmode} from "@main/interfaces/IERC1363WithGodmode.sol";

contract ERC1363WithGodmodeSetupScript is Test, RegisterScripts, Constants {
    struct Constructors_erc1363WithGodmode {
        string name;
        string symbol;
        address initialOwner;
        address initialSanctionAdmin;
    }

    Constructors_erc1363WithGodmode arg_erc1363WithGodmode;

    IERC1363WithGodmode ERC1363WithGodmode;

    /**
     * @dev SCRIPTS_MOCK_ADDRESS is hard-coded as false
     */
    function setUpContracts() internal virtual {
        if (SCRIPTS_MOCK_ADDRESS) setUpMock();
        else setUpHarness();
    }

    /**
     * @dev There is no mocking contract here
     */
    function setUpMock() private view {
        throwError("There is no mock here");
    }

    function setUpHarness() private {
        arg_erc1363WithGodmode.name = "Test Sanction Token";
        arg_erc1363WithGodmode.symbol = "SANC";
        arg_erc1363WithGodmode.initialOwner = msg.sender;
        arg_erc1363WithGodmode.initialSanctionAdmin = msg.sender;

        bytes memory constructors = abi.encode(
            arg_erc1363WithGodmode.name,
            arg_erc1363WithGodmode.symbol,
            arg_erc1363WithGodmode.initialOwner,
            arg_erc1363WithGodmode.initialSanctionAdmin
        );
        address deployed = setUpContract("ERC1363WithGodmode", constructors, "ERC1363WithGodmode");
        ERC1363WithGodmode = IERC1363WithGodmode(deployed);
    }

    function unitTest_Deployment() internal virtual {}

    function integrationTest_Deployment() internal virtual {
        // assertEq(ERC1363WithGodmode.owner(), arguments.initialOwner);
        // assertEq(ERC1363WithGodmode.god(), arguments.initialGod);
    }
}
