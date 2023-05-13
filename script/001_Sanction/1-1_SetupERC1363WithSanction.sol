// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {Test} from "@forge-std/Test.sol";
import {RegisterScripts} from "../RegisterScripts.sol";

import {Constants} from "../Constants.sol";
// import {ISanctionRoles} from "@main/interfaces/ISanctionRoles.sol";
import {IERC1363WithSanction} from "@main/interfaces/IERC1363WithSanction.sol";

contract ERC1363WithSanctionSetupScript is Test, RegisterScripts, Constants {
    struct Constructors_erc1363WithSanction {
        string name;
        string symbol;
        address initialOwner;
        address initialSanctionAdmin;
        address initialMinter;
    }

    Constructors_erc1363WithSanction arg_erc1363WithSanction;

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
    function setUpMock() private view {
        throwError("There is no mock here");
    }

    function setUpHarness() private {
        arg_erc1363WithSanction.name = "Test Sanction Token";
        arg_erc1363WithSanction.symbol = "SANC";
        arg_erc1363WithSanction.initialOwner = msg.sender;
        arg_erc1363WithSanction.initialSanctionAdmin = msg.sender;
        arg_erc1363WithSanction.initialMinter = msg.sender;

        bytes memory constructors = abi.encode(
            arg_erc1363WithSanction.name,
            arg_erc1363WithSanction.symbol,
            arg_erc1363WithSanction.initialOwner,
            arg_erc1363WithSanction.initialSanctionAdmin,
            arg_erc1363WithSanction.initialMinter
        );
        address deployed = setUpContract("ERC1363WithSanction", constructors, "ERC1363WithSanction");
        erc1363WithSanction = IERC1363WithSanction(deployed);
    }

    function unitTest_Deployment() internal virtual {}

    function integrationTest_Deployment() internal virtual {
        // assertEq(erc1363WithSanction.owner(), arguments.initialOwner);
        // assertEq(erc1363WithSanction.sanctionAdmin(), arguments.initialSanctionAdmin);
    }
}
