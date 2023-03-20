// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {ERC1363WithSanction} from "@main/ERC1363WithSanction.sol";


contract DeploymentERC1363WithSanction {

    struct Constructors_erc1363WithSanction {
        string name;
        string symbol;
        address initialOwner;
        address initialSanctionAdmin;
        address initialMinter;
    }
    Constructors_erc1363WithSanction arg_erc1363WithSanction;

    function deployAndSetup(
        Constructors_erc1363WithSanction storage arg_erc1363WithSanction_
    ) internal returns(address saleToken) {

        saleToken = address(new ERC1363WithSanction(
            arg_erc1363WithSanction_.name,
            arg_erc1363WithSanction_.symbol,
            arg_erc1363WithSanction_.initialOwner,
            arg_erc1363WithSanction_.initialSanctionAdmin,
            arg_erc1363WithSanction_.initialMinter
        ));

    }

}