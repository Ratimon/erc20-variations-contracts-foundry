// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Test} from "@forge-std/Test.sol";
import {RegisterScripts} from "../RegisterScripts.sol";

import {Constants} from "../Constants.sol";
// import {ISanctionRoles} from "@main/interfaces/ISanctionRoles.sol";
import {IERC1363WithSanction} from "@main/interfaces/IERC1363WithSanction.sol";


contract ERC1363WithSanctionSetupScript is Test, RegisterScripts, Constants  {
    

    struct Constructors {
        string name;
        string symbol;
        address initialOwner;
        address initialSanctionAdmin;
    }

    Constructors arguments;

    IERC1363WithSanction erc1363WithSanction;

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

        arguments.name = "Test Sanction Token";
        arguments.symbol = "SANC";
        arguments.initialOwner = msg.sender;
        arguments.initialSanctionAdmin = msg.sender;

        bytes memory constructors = abi.encode(arguments.name, arguments.symbol,  arguments.initialOwner, arguments.initialSanctionAdmin);
        address deployed = setUpContract("ERC1363WithSanction",constructors, "ERC1363WithSanction");
        erc1363WithSanction = IERC1363WithSanction(deployed);

    }

    function unitTest_Deployment() internal virtual {

    }

    function integrationTest_Deployment() internal virtual {

        // assertEq(erc1363WithSanction.owner(), arguments.initialOwner);
        // assertEq(erc1363WithSanction.sanctionAdmin(), arguments.initialSanctionAdmin);

    }

}