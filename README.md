# hyperledger-fabric-2.0

This project contain 5 orderer with 3 ca and 4 peers network.Still work in progess

### Steps to run fabric

* Create the crypto file using the below command

    `bash ./cryptogen.sh`

* Create the genesis file using the below command

    `bash ./configtx.sh`

* Run the docker-compose which contains all network

    `docker-compose -f ./docker/docker-compose-raft.yaml up -d `

* To stop the container use below command
    `docker-compose -f ./docker/docker-compose-raft.yaml down`


* To remove the unsued volume
    `docker system prune --volumes`

* To create the channel Tx and Anchor Tx inside the channel-artifacts
    `bash scripts/channel.sh`

* Peer will join the channel
    `bash scripts/joinchannel.sh`


Note: Before running the join channel command, you need to run the docker container