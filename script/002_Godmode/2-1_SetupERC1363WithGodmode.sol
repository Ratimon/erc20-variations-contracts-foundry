// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Test} from "@forge-std/Test.sol";
import {RegisterScripts} from "../RegisterScripts.sol";

import {Constants} from "../Constants.sol";
import {IERC1363WithGodmode} from "@main/interfaces/IERC1363WithGodmode.sol";


contract ERC1363WithGodmodeSetupScript is Test, RegisterScripts, Constants  {

    struct Constructors {
        string name;
        string symbol;
        address initialOwner;
        address initialGod;
    }

    Constructors arguments;
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
    function setUpMock() view private  {
        throwError("There is no mock here");
    }

    function setUpHarness() private  {

        arguments.name = "GOD Token";
        arguments.symbol = "GOD";
        arguments.initialOwner = msg.sender;
        arguments.initialGod = msg.sender;

        bytes memory constructors = abi.encode(arguments.name, arguments.symbol,  arguments.initialOwner, arguments.initialGod);
        address deployed = setUpContract("ERC1363WithGodmode",constructors, "ERC1363WithGodmode");
        ERC1363WithGodmode = IERC1363WithGodmode(deployed);

    }

    function unitTest_Deployment() internal virtual {

    }

    function integrationTest_Deployment() internal virtual {

        assertEq(ERC1363WithGodmode.owner(), arguments.initialOwner);
        assertEq(ERC1363WithGodmode.god(), arguments.initialGod);

    }


}