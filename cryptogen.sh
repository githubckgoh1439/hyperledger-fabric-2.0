export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false



    echo
    echo "##########################################################"
    echo "##### Generate certificates using cryptogen tool #########"
    echo "##########################################################"
    echo

    echo "##########################################################"
    echo "############ Create Org1 Identities ######################"
    echo "##########################################################"


 ./bin/cryptogen generate --config=./organizations/cryptogen/crypto-config-org1.yaml --output="organizations"

    echo "##########################################################"
    echo "############ Create Org2 Identities ######################"
    echo "##########################################################"

./bin/cryptogen generate --config=./organizations/cryptogen/crypto-config-org2.yaml --output="organizations"

    echo "##########################################################"
    echo "############ Create Orderer Org Identities ###############"
    echo "##########################################################"


./bin/cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output="organizations"