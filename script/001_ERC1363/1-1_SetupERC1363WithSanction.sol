// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {Test} from "@forge-std/Test.sol";
import {RegisterScripts} from "../RegisterScripts.sol";

import {Constants} from "../Constants.sol";


contract ERC1363WithSanctionSetupScript is Test, RegisterScripts, Constants  {
    

    struct Constructors {
        string name;
        string symbol;
        address  initialOwner;
        address  initialSanctionAdmin;
    }

    Constructors ERC1363WithSanction;
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

        ERC1363WithSanction.name = "Test Token";
        ERC1363WithSanction.symbol = "TEST";
        ERC1363WithSanction.initialOwner = msg.sender;
        ERC1363WithSanction.initialSanctionAdmin = msg.sender;

        bytes memory constructors = abi.encode(ERC1363WithSanction.name, ERC1363WithSanction.symbol,  ERC1363WithSanction.initialOwner, ERC1363WithSanction.initialSanctionAdmin);
        setUpContract("ERC1363WithSanction",constructors, "ERC1363WithSanction");

    }

    function unitTest_Deployment() internal virtual {

    }

    function integrationTest_Deployment() internal view virtual {

    }

}