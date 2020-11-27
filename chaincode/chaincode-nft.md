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

--------------------------------------------------- stop here : 1936
### Set the MSCONFIGPATH of peer of admin

`export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.sample.com/users/Org1_hr@org1.sample.com/msp`

### Create the package of the chaincode


* NFT
`peer lifecycle chaincode package nft.tar.gz --path ./chaincode/nft/go/ --lang golang --label nft_1`



## Steps for install the chaincode

### Set the core peer address for peer0.org0

        export CORE_PEER_TLS_ENABLED=true
        export CORE_PEER_LOCALMSPID="Org1MSP"
        export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.sample.com/peers/peer0.org1.sample.com/tls/ca.crt
        export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.sample.com/users/Org1_hr@org1.sample.com/msp
        export CORE_PEER_ADDRESS=localhost:7051

### Install the chain code using tar file



 * NFT
 `peer lifecycle chaincode install nft.tar.gz`



 ### Set the core peer address for peer0.org2

        export CORE_PEER_LOCALMSPID="Org2MSP"
        export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/tls/ca.crt
        export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/tls/ca.crt
        export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.sample.com/users/Org2_hr@org2.sample.com/msp
        export CORE_PEER_ADDRESS=localhost:9051

### Install the chain code using tar file



* Nft
 `peer lifecycle chaincode install nft.tar.gz`


### Steps for Approve the chain-code

#### query the chaincode to get the Package ID

`peer lifecycle chaincode queryinstalled`

`export CC_PACKAGE_ID=nft_1:388e32a7bc67be280de6917f9eacae5f55425c14af5a47b4af3a3cd8722facf0`

### Aprove the chain code

        export CORE_PEER_LOCALMSPID="Org1MSP"
        export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.sample.com/users/Org1_hr@org1.sample.com/msp
        export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.sample.com/peers/peer0.org1.sample.com/tls/ca.crt
        export CORE_PEER_ADDRESS=localhost:7051



* Nft
`peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.sample.com --channelID mychannel --name nft --version 1.0 --init-required --package-id ${CC_PACKAGE_ID} --sequence 1 --tls true --cafile ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/msp/tlscacerts/tlsca.sample.com-cert.pem`

        export CORE_PEER_LOCALMSPID="Org2MSP"
        export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/tls/ca.crt
        export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/tls/ca.crt
        export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.sample.com/users/Org2_hr@org2.sample.com/msp
        export CORE_PEER_ADDRESS=localhost:9051



* Nft
`peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.sample.com --channelID mychannel --name nft --version 1.0 --init-required --package-id ${CC_PACKAGE_ID} --sequence 1 --tls true --cafile ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/msp/tlscacerts/tlsca.sample.com-cert.pem`




### commiting the chain-code



* Nft
`peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name nft --version 1.0 --init-required --sequence 1 --tls true --cafile ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/msp/tlscacerts/tlsca.sample.com-cert.pem --output json`




* Nft
`peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.sample.com --channelID mychannel --name nft --version 1.0 --sequence 1 --init-required --tls true --cafile ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/msp/tlscacerts/tlsca.sample.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.sample.com/peers/peer0.org1.sample.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/tls/ca.crt`



### Get the sequence and version of chaincode



* Nft
`peer lifecycle chaincode querycommitted --channelID mychannel --name nft --cafile ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/msp/tlscacerts/tlsca.sample.com-cert.pem`


#### Invoking the chain-code

* Nft
`peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.sample.com --tls true --cafile ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/msp/tlscacerts/tlsca.sample.com-cert.pem -C mychannel -n nft --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.sample.com/peers/peer0.org1.sample.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/tls/ca.crt --isInit -c '{"function":"InitLedger","Args":[]}'`

#### Now we can query the chain-code

`peer chaincode query -C mychannel -n nft -c '{"Args":["queryAllnft"]}'`

`peer chaincode query -C mychannel -n nft -c '{"Args":["getTokenInfo","symbol0"]}'`

`peer chaincode query -C mychannel -n nft -c '{"function":"getTokenInfo","Args":["symbol0"]}' >&log.txt`
