# hyperledger-fabric-2.0

This project contain 5 orderer with 3 ca and 4 peers network.Still work in progess

### Steps to run fabric


### Create the crypto keys running Certificate Authority

* Use below command which bring up the ca_org1, ca_org2, ca_orderer & which will create the peer,ca-admin,orderer keypairs

    `bash ./scripts/ca.sh`

* Create the genesis file using the below command

    `bash ./configtx.sh`

* Run the docker-compose which contains all network

    `docker-compose -f ./docker/docker-compose-raft.yaml up -d `

* To stop the container use below command

    `docker-compose -f ./docker/docker-compose-raft.yaml down`


* To remove the unsued volume
    `docker system prune --volumes`

* To create the channel Tx and Anchor Tx inside the channel-artifacts

    `bash ./scripts/channel/channel.sh`

* Peer will join the channel

    `bash ./scripts/channel/peer-join-channel.sh`

* Anchor-Peer update the channel

    `bash ./scripts/channel/update-Anchor.sh`


### Deploy the chain-code

 `bash ./scripts/chain-code/deployCC.sh`

Note: Before running the join channel command, you need to run the docker container



* Another way to create the crypto file using the below command

    `bash ./cryptogen.sh`