#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n        /g'
}

ORG=1
P0PORT=7051
CAPORT=7054
PEERPEM=organizations/peerOrganizations/org1.sample.com/tlsca/tlsca.org1.sample.com-cert.pem
CAPEM=organizations/peerOrganizations/org1.sample.com/ca/ca.org1.sample.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org1.sample.com/connection-org1.json
# echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org1.sample.com/connection-org1.yaml

ORG=2
P0PORT=9051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/org2.sample.com/tlsca/tlsca.org2.sample.com-cert.pem
CAPEM=organizations/peerOrganizations/org2.sample.com/ca/ca.org2.sample.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org2.sample.com/connection-org2.json
# echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org2.sample.com/connection-org2.yaml


# ###
# ORG=orderer
# P0PORT=10051
# CAPORT=9054
# PEERPEM=organizations/ordererOrganizations/sample.com/orderers/orderer5.sample.com/tls/tlscacerts/tlsca.orderer5.sample.com-cert.pem
# CAPEM=organizations/ordererOrganizations/sample.com/orderers/orderer5.sample.com/tls/cacerts/ca.orderer5.sample.com-cert.pem
# echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/ordererOrganizations/sample.com/orderers/orderer5.sample.com/connection-orderer.json
