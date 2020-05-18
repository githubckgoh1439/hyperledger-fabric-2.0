
### Export the config for peer form core.yaml
export PATH=${PWD}/./bin:${PWD}:$PATH

### Export the config for peer form core.yaml
export FABRIC_CFG_PATH=$PWD/config/


function createOrgs() {
    echo
    echo "##########################################################"
    echo "##### Generate certificates using Fabric CA's ############"
    echo "##########################################################"

    IMAGE_TAG=$IMAGETAG docker-compose -f $COMPOSE_FILE_CA up -d 2>&1

    . organizations/fabric-ca/registerEnroll.sh

    sleep 10

    echo "##########################################################"
    echo "############ Create Org1 Identities ######################"
    echo "##########################################################"

    createOrg1

    echo "##########################################################"
    echo "############ Create Org2 Identities ######################"
    echo "##########################################################"

    createOrg2

    echo "##########################################################"
    echo "############ Create Org2 Orderer ######################"
    echo "##########################################################"

    createOrderer

 echo
  echo "Generate CCP files for Org1 and Org2"
  ./organizations/ccp-generate.sh
}



# channel name defaults to "mychannel"
CHANNEL_NAME="mychannel"
# use this as the default docker-compose yaml definition
COMPOSE_FILE_BASE=docker/docker-compose-raft.yaml
# docker-compose.yaml file if you are using couchdb
COMPOSE_FILE_COUCH=docker/docker-compose-couch.yaml
# certificate authorities compose file
COMPOSE_FILE_CA=docker/docker-compose-ca.yaml

# use golang as the default language for chaincode
CC_SRC_LANGUAGE=golang
# Chaincode version
VERSION=1
# default image tag
IMAGETAG="latest"
# default database
DATABASE="leveldb"



createOrgs