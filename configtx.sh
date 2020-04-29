
export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false


    echo
    echo "##########################################################"
    echo "##### Generate Genesis using Configtx tool #########"
    echo "##########################################################"
    echo

./bin/configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block