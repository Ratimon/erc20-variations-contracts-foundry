// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import {ERC1363WithSanctionSetupScript} from "./1-1_SetupERC1363WithSanction.sol";

contract ONE_deployERC1363WithSanction is ERC1363WithSanctionSetupScript {


    function setUpScripts() internal override {
        // We only want to attach existing contracts.
        // Though if everything is up-to-date, this should be redundant and not needed.
        // SCRIPTS_ATTACH_ONLY = true; // disables re-deploying
        SCRIPTS_MOCK_ADDRESS = false; // not use contracts addresses from mainnet

        // The following variables can all be set to change the behavior of the scripts.
        // These can also all be set through passing the argument in the command line
        // e.g: SCRIPTS_RESET=true forge script ...

        // SCRIPTS_RESET; // re-deploys all contracts
        // SCRIPTS_BYPASS; // deploys contracts without any checks whatsoever
        // SCRIPTS_DRY_RUN; // doesn't actually boradcast and store transaction on chain but still simulate deployment Tx
        // SCRIPTS_CONFIRM; // confirm saving on deployments/production when running on mainnet
        // SCRIPTS_ATTACH_ONLY; // doesn't deploy contracts, just attaches with checks
        // SCRIPTS_MOCK_ADDRESS; // doesn't use contracts addresses from mainnet
    }



    function run() external {

        // will run `vm.startBroadcast();` if ffi is enabled
        // ffi is required for running storage layout compatibility checks
        // if ffi is disabled, it will enter "dry-run" and
        // run `vm.startPrank(tx.origin)` instead for the script to be consistent
        startBroadcastIfNotDryRun();

        // run the setup scripts
        setUpContracts();

        // we don't need broadcast from here on
        vm.stopBroadcast();

        if(SCRIPTS_MOCK_ADDRESS) {
            // run an "unit test"
            unitTest();
        } else {
            // run an "integration test"
            integrationTest();
        } 

        // console.log and store these in `deployments/` (if not in dry-run)
        storeLatestDeployments();
        savePastDeployments();
    }


}