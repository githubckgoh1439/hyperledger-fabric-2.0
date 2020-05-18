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

`export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.avantas.com/users/Admin@org1.avantas.com/msp`

### Create the package of the chaincode

* fabcar
`peer lifecycle chaincode package fabcar.tar.gz --path ./chaincode/fabcar/go/ --lang golang --label fabcar_1`




## Steps for install the chaincode

### Set the core peer address for peer0.org0

        export CORE_PEER_TLS_ENABLED=true
        export CORE_PEER_LOCALMSPID="Org1MSP"
        export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com/tls/ca.crt
        export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.avantas.com/users/Admin@org1.avantas.com/msp
        export CORE_PEER_ADDRESS=localhost:7051

### Install the chain code using tar file

* fabcar
 `peer lifecycle chaincode install fabcar.tar.gz`

#### query the chaincode to get the Package ID

`peer lifecycle chaincode queryinstalled`

`export CC_PACKAGE_ID=fabcar_1:65710fa851d5c73690faa4709ef40b798c085e7210c46d44f8b1e2d5a062c9b0`

* ### Aprove the chain code fabcar peer0.org0

`peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.avantas.com --channelID mychannel --name fabcar --version 1.0 --init-required --package-id ${CC_PACKAGE_ID} --sequence 1 --tls true --cafile ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem`

 ### Set the core peer address for peer0.org2

        export CORE_PEER_LOCALMSPID="Org2MSP"
        export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.avantas.com/peers/peer0.org2.avantas.com/tls/ca.crt
        export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.avantas.com/users/Admin@org2.avantas.com/msp
        export CORE_PEER_ADDRESS=localhost:9051

### Install the chain code using tar file

* fabcar
 `peer lifecycle chaincode install fabcar.tar.gz`



### Aprove the chain code peer0.org1


* fabcar
`peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.avantas.com --channelID mychannel --name fabcar --version 1.0 --init-required --package-id ${CC_PACKAGE_ID} --sequence 1 --tls true --cafile ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem`


### commiting the chain-code

* fabcar
`peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name fabcar --version 1.0 --init-required --sequence 1 --tls true --cafile ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem --output json`



* fabcar
`peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.avantas.com --channelID mychannel --name fabcar --version 1.0 --sequence 1 --init-required --tls true --cafile ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.avantas.com/peers/peer0.org2.avantas.com/tls/ca.crt`





### Get the sequence and version of chaincode

* fabcar
`peer lifecycle chaincode querycommitted --channelID mychannel --name fabcar --cafile ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem`




#### Invoking the chain-code

* fabcar
`peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.avantas.com --tls true --cafile ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem -C mychannel -n fabcar --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.avantas.com/peers/peer0.org2.avantas.com/tls/ca.crt --isInit -c '{"function":"InitLedger","Args":[]}`'


peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.avantas.com --tls true --cafile ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem -C mychannel -n fabcar --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com/tls/ca.crt --isInit -c '{"function":"InitLedger","Args":[]}'


#### Now we can query the chain-code

`peer chaincode query -C mychannel -n fabcar -c '{"Args":["queryAllCars"]}'`

`peer chaincode query -C mychannel -n fabcar -c '{"Args":["queryCar","CAR0"]}'`
