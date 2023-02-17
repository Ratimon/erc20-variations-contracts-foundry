-include .env

# delete-deployment path1=test path2=1337
delete-deployment:
	DEPLOYMENT_DIRECTORY_NAME=$(call deployment_directory,$(path1),$(path2)) bash ./utils/clean-deployment.sh

# spin node
anvil-node:
	anvil --chain-id 1337

fork-node: 
	ETH_RPC_URL=$(call network,mainnet) FORK_BLOCK_NUMBER=$(call block_number) LOCAL_CHAIN_ID=$(call local_chain_id)  bash ./utils/node.sh

void-deploy-sanction:
	make delete-deployment path1=test path2=1337; \
	forge script ONE_deployERC1363WithSanction --rpc-url $(call local_network,8545)  -vvvv --broadcast --ffi; \

void-deploy-god:
	make delete-deployment path1=test path2=1337; \
	forge script ONE_deployERC1363WithGodmode --rpc-url $(call local_network,8545)  -vvvv --broadcast --ffi; \

# fork-deploy:
# 	make delete-deployment path1=test path2=1337
# 	forge script ONE_deployERC1363WithSanction --rpc-url $(call local_network,8545)  -vvv --ffi

# production-deploy:
# 	make delete-deployment path1=production path2=1
# 	check-api-key
# 	US_CONFIRM=true forge script ONE_deployERC1363WithSanction --rpc-url $(call network,mainnet)  -vvv --broadcast --ffi -t --sender $(call sender_address)




unit-test-ERC1363WithSanctionRoles:
	forge test --match-path test/unit/ERC1363WithSanction.Roles.t.sol -vvv

unit-test-ERC1363WithSanction:
	forge test --match-path test/unit/ERC1363WithSanction.t.sol -vvv

unit-test-LinearCurve:
	forge test --match-path test/unit/LinearCurve.t.sol -vvv

integration-test-ERC1363WithSanction:
	forge test --match-path test/integration/ERC1363WithSanction.t.sol --fork-url  $(call local_network,8545) -vvv

# integration-coverage-ERC1363WithSanction:
# 	forge coverage --match-contract TestERC1363WithSanction --fork-url  $(call local_network,8545) -vvv

unit-test-ERC1363WithGodmode:
	forge test --match-path test/unit/ERC1363WithGodmode.t.sol -vvv

integration-test-ERC1363WithGodmode:
	forge test --match-path test/integration/ERC1363WithGodmode.t.sol --fork-url  $(call local_network,8545) -vvv

# --match-test to filter test functions, --match-contract to filter test contracts, and --match-path
# --mt

check-api-key:
ifndef ALCHEMY_API_KEY
	$(error ALCHEMY_API_KEY is undefined)
endif

define deployment_directory
deployments/$1/$2
endef

# Returns the URL to deploy to a hosted node.
# Requires the ALCHEMY_API_KEY env var to be set.
# The first argument determines the network (mainnet / rinkeby / ropsten / kovan / goerli)
define network
https://eth-$1.g.alchemy.com/v2/${ALCHEMY_API_KEY}
endef

define local_network
http://127.0.0.1:$1
endef

define block_number
${FORK_BLOCK_NUMBER}
endef

define sender_address
${SENDER_ADDRESS}
endef

define local_chain_id
${LOCAL_CHAIN_ID}
endef
