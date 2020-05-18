
export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/config
export VERBOSE=false
export CHANNEL_NAME="mychannel"


# channel
 mkdir channel-artifacts

# create channel
    echo
    echo "##########################################################"
    echo "##### Generate Channel using configtxgen tool #########"
    echo "##########################################################"
    echo
./bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME

sleep 10
# create Anchor peer


    echo
    echo "##########################################################"
    echo "##### Generate Anchor peer using configtxgen tool #########"
    echo "##########################################################"
    echo
./bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP


./bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP




# Join channel block

# Organisation
#org-1

# peer0
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem
    export FABRIC_CFG_PATH=${PWD}/config
    export PEER0_ORG1_CA=${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com/tls/ca.crt
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.avantas.com/users/Admin@org1.avantas.com/msp
    export CORE_PEER_ADDRESS=localhost:7051


# create channel block


    echo
    echo "##########################################################"
    echo "##### create channel block using configtxgen tool #########"
    echo "##########################################################"
    echo
./bin/peer channel create -o localhost:7050 -c $CHANNEL_NAME --ordererTLSHostnameOverride orderer.avantas.com -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

sleep 10
# Join peer


    echo
    echo "##########################################################"
    echo "##### peerO join channel using configtxgen tool #########"
    echo "##########################################################"
    echo
./bin/peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

sleep 10

    echo
    echo "##########################################################"
    echo "##### update anchor using configtxgen tool #########"
    echo "##########################################################"
    echo
./bin/peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.avantas.com -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt



# Peer1 anchor peer

    # export PEER1_ORG1_CA=${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer1.org1.avantas.com/tls/ca.crt

    # export CORE_PEER_LOCALMSPID="Org1MSP"
    # export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG1_CA
    # export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.avantas.com/users/Admin@org1.avantas.com/msp
    # export CORE_PEER_ADDRESS=localhost:7051



#org-2

# peer0

   export CORE_PEER_TLS_ENABLED=true
   export ORDERER_CA=${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem
    export PEER0_ORG2_CA=${PWD}/organizations/peerOrganizations/org2.avantas.com/peers/peer0.org2.avantas.com/tls/ca.crt
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.avantas.com/users/Admin@org2.avantas.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

    echo
    echo "##########################################################"
    echo "##### peer1 join channel using configtxgen tool #########"
    echo "##########################################################"
    echo

./bin/peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
sleep 10
    echo
    echo "##########################################################"
    echo "##### peer1 join channel using configtxgen tool #########"
    echo "##########################################################"
    echo
./bin/peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.avantas.com -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt

# Peer1 anchor peer

    # export PEER1_ORG2_CA=${PWD}/organizations/peerOrganizations/org2.avantas.com/peers/peer1.org2.avantas.com/tls/ca.crt

    # export CORE_PEER_LOCALMSPID="Org2MSP"
    # export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG2_CA
    # export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.avantas.com/users/Admin@org2.avantas.com/msp
    # export CORE_PEER_ADDRESS=localhost:9051

