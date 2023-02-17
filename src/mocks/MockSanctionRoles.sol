// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {SanctionRoles} from "@main/roles/SanctionRoles.sol";

contract MockSanctionRoles is SanctionRoles {
    constructor(
        address initialOwner,
        address initialSanctionAdmin,
        address initialMinter
        ) SanctionRoles(initialOwner,initialSanctionAdmin,initialMinter)  {
    }
}
