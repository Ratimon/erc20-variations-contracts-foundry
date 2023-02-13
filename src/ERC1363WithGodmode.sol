// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;


import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {Errors} from "./shared/Error.sol";
import {ERC1363Base} from "./base/ERC1363Base.sol";

/**
 * @notice ERC1363 with god mode. It allows an admin to ban specified addresses from sending and receiving tokens.
 */
contract ERC1363WithGodmode is ERC1363Base{

    /**
     * @notice erc1363 with sanction constructor
     * @param name token name for ERC1363
     * @param symbol token symbol for ERC1363
     */
    constructor(
        string memory name,
        string memory symbol
        ) ERC20(name, symbol){

    }

}