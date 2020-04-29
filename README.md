# hyperledger-fabric-2.0

This project contain 5 orderer with 3 ca and 4 peers network.Still work in progess

### Steps to run fabric

* Create the crypto file using the below command

`./cryptogen.sh`

* Run the docker-compose which contains all network

`docker-compose -f ./docker/docker-compose-test-net.yaml up -d `

* To stop the container use below command
`docker-compose -f ./docker/docker-compose-test-net.yaml down`
