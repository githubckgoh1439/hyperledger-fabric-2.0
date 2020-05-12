Chain-code package


## Steps for packaging the chaincode

### Inside the chaincode/fabcar/go

`GO111MODULE=on go mod vendor`

### Export the peer binary inside the bin folder

`export PATH=${PWD}/./bin:${PWD}:$PATH`


### Export the config for peer form core.yaml

`export FABRIC_CFG_PATH=$PWD/config/`

### check the peer version
`peer version`


### Set the MSCONFIGPATH of peer of admin

`export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp`

### Create the package of the chaincode


* NFT
`peer lifecycle chaincode package nft.tar.gz --path ./chaincode/nft/go/ --lang golang --label nft_1`



## Steps for install the chaincode

### Set the core peer address for peer0.org0

        export CORE_PEER_TLS_ENABLED=true
        export CORE_PEER_LOCALMSPID="Org1MSP"
        export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
        export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
        export CORE_PEER_ADDRESS=localhost:7051

### Install the chain code using tar file



 * NFT
 `peer lifecycle chaincode install nft.tar.gz`



 ### Set the core peer address for peer0.org2

        export CORE_PEER_LOCALMSPID="Org2MSP"
        export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
        export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
        export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
        export CORE_PEER_ADDRESS=localhost:9051

### Install the chain code using tar file



* Nft
 `peer lifecycle chaincode install nft.tar.gz`


### Steps for Approve the chain-code

#### query the chaincode to get the Package ID

`peer lifecycle chaincode queryinstalled`

`export CC_PACKAGE_ID=nft_1:9f66bbe0a5b2f2ddb76e37507243dbf320be29e34471355c646ed785bfd7ff00`

### Aprove the chain code

        export CORE_PEER_LOCALMSPID="Org1MSP"
        export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
        export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
        export CORE_PEER_ADDRESS=localhost:7051



* Nft
`peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name nft --version 1.0 --init-required --package-id ${CC_PACKAGE_ID} --sequence 1 --tls true --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem`

        export CORE_PEER_LOCALMSPID="Org2MSP"
        export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
        export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
        export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
        export CORE_PEER_ADDRESS=localhost:9051



* Nft
`peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name nft --version 1.0 --init-required --package-id ${CC_PACKAGE_ID} --sequence 1 --tls true --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem`




### commiting the chain-code



* Nft
`peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name nft --version 1.0 --init-required --sequence 1 --tls true --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json`




* Nft
`peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name nft --version 1.0 --sequence 1 --init-required --tls true --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt`



### Get the sequence and version of chaincode



* Nft
`peer lifecycle chaincode querycommitted --channelID mychannel --name nft --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem`


#### Invoking the chain-code

* Nft
`peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n nft --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --isInit -c '{"function":"InitLedger","Args":[]}'`

#### Now we can query the chain-code

`peer chaincode query -C mychannel -n fabcar -c '{"Args":["queryAllCars"]}'`

`peer chaincode query -C mychannel -n nft -c '{"Args":["getTokenInfo","22_symbol"]}'`

`peer chaincode query -C mychannel -n nft -c '{"function":"getTokenInfo","Args":["22_symbol"]}' >&log.txt`
