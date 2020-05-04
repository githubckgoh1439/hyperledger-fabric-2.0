# hyperledger-fabric-2.0
### develop branch

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

