
function createOrg1 {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/org1.avantas.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.avantas.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-org1 --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/org1.avantas.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-org1 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-org1 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-org1 --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/org1.avantas.com/peers
  mkdir -p organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com/msp --csr.hosts peer0.org1.avantas.com --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org1.avantas.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com/tls --enrollment.profile tls --csr.hosts peer0.org1.avantas.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/org1.avantas.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.avantas.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/org1.avantas.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.avantas.com/tlsca/tlsca.org1.avantas.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/org1.avantas.com/ca
  cp ${PWD}/organizations/peerOrganizations/org1.avantas.com/peers/peer0.org1.avantas.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org1.avantas.com/ca/ca.org1.avantas.com-cert.pem

  mkdir -p organizations/peerOrganizations/org1.avantas.com/users
  mkdir -p organizations/peerOrganizations/org1.avantas.com/users/User1@org1.avantas.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.avantas.com/users/User1@org1.avantas.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  mkdir -p organizations/peerOrganizations/org1.avantas.com/users/Admin@org1.avantas.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.avantas.com/users/Admin@org1.avantas.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org1.avantas.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.avantas.com/users/Admin@org1.avantas.com/msp/config.yaml

}


function createOrg2 {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/org2.avantas.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org2.avantas.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-org2 --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/org2.avantas.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-org2 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-org2 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-org2 --id.name org2admin --id.secret org2adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/org2.avantas.com/peers
  mkdir -p organizations/peerOrganizations/org2.avantas.com/peers/peer0.org2.avantas.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.avantas.com/peers/peer0.org2.avantas.com/msp --csr.hosts peer0.org2.avantas.com --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org2.avantas.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.avantas.com/peers/peer0.org2.avantas.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.avantas.com/peers/peer0.org2.avantas.com/tls --enrollment.profile tls --csr.hosts peer0.org2.avantas.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/org2.avantas.com/peers/peer0.org2.avantas.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.avantas.com/peers/peer0.org2.avantas.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org2.avantas.com/peers/peer0.org2.avantas.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org2.avantas.com/peers/peer0.org2.avantas.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org2.avantas.com/peers/peer0.org2.avantas.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org2.avantas.com/peers/peer0.org2.avantas.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/org2.avantas.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org2.avantas.com/peers/peer0.org2.avantas.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.avantas.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/org2.avantas.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org2.avantas.com/peers/peer0.org2.avantas.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.avantas.com/tlsca/tlsca.org2.avantas.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/org2.avantas.com/ca
  cp ${PWD}/organizations/peerOrganizations/org2.avantas.com/peers/peer0.org2.avantas.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org2.avantas.com/ca/ca.org2.avantas.com-cert.pem

  mkdir -p organizations/peerOrganizations/org2.avantas.com/users
  mkdir -p organizations/peerOrganizations/org2.avantas.com/users/User1@org2.avantas.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.avantas.com/users/User1@org2.avantas.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  mkdir -p organizations/peerOrganizations/org2.avantas.com/users/Admin@org2.avantas.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://org2admin:org2adminpw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.avantas.com/users/Admin@org2.avantas.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org2.avantas.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.avantas.com/users/Admin@org2.avantas.com/msp/config.yaml

}

function createOrderer {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/ordererOrganizations/avantas.com

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/avantas.com
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/ordererOrganizations/avantas.com/msp/config.yaml

# orderer
  echo
	echo "Register orderer"
  echo
  set -x
	fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

  echo
  echo "Register the orderer admin"
  echo
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

	mkdir -p organizations/ordererOrganizations/avantas.com/orderers
  mkdir -p organizations/ordererOrganizations/avantas.com/orderers/avantas.com

  mkdir -p organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com

  echo
  echo "## Generate the orderer msp"
  echo
  set -x
	fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/msp --csr.hosts orderer.avantas.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/avantas.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/tls --enrollment.profile tls --csr.hosts orderer.avantas.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/tls/server.key

  mkdir ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem

  mkdir ${PWD}/organizations/ordererOrganizations/avantas.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer.avantas.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem

  mkdir -p organizations/ordererOrganizations/avantas.com/users
  mkdir -p organizations/ordererOrganizations/avantas.com/users/Admin@avantas.com

  echo
  echo "## Generate the admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/avantas.com/users/Admin@avantas.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/avantas.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/avantas.com/users/Admin@avantas.com/msp/config.yaml

# orderer 2

echo
	echo "Register orderer2"
  echo
  set -x
	fabric-ca-client register --caname ca-orderer --id.name orderer2 --id.secret orderer2pw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

  mkdir -p organizations/ordererOrganizations/avantas.com/orderers/orderer2.avantas.com


  echo
  echo "## Generate the orderer msp"
  echo
  set -x
	fabric-ca-client enroll -u https://orderer2:orderer2pw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer2.avantas.com/msp --csr.hosts orderer2.avantas.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/avantas.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer2.avantas.com/msp/config.yaml


  echo
  echo "## Generate the orderer-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer2:orderer2pw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer2.avantas.com/tls --enrollment.profile tls --csr.hosts orderer2.avantas.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer2.avantas.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer2.avantas.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer2.avantas.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer2.avantas.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer2.avantas.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer2.avantas.com/tls/server.key

  mkdir ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer2.avantas.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer2.avantas.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer2.avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem

  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer2.avantas.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem

# orderer3

echo
	echo "Register orderer3"
  echo
  set -x
	fabric-ca-client register --caname ca-orderer --id.name orderer3 --id.secret orderer3pw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

  mkdir -p organizations/ordererOrganizations/avantas.com/orderers/orderer3.avantas.com


  echo
  echo "## Generate the orderer msp"
  echo
  set -x
	fabric-ca-client enroll -u https://orderer3:orderer3pw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer3.avantas.com/msp --csr.hosts orderer3.avantas.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/avantas.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer3.avantas.com/msp/config.yaml


  echo
  echo "## Generate the orderer-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer3:orderer3pw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer3.avantas.com/tls --enrollment.profile tls --csr.hosts orderer3.avantas.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer3.avantas.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer3.avantas.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer3.avantas.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer3.avantas.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer3.avantas.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer3.avantas.com/tls/server.key

  mkdir ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer3.avantas.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer3.avantas.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer3.avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem

  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer3.avantas.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem

 # Ordrer 4

 echo
	echo "Register orderer4"
  echo
  set -x
	fabric-ca-client register --caname ca-orderer --id.name orderer4 --id.secret orderer4pw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

  mkdir -p organizations/ordererOrganizations/avantas.com/orderers/orderer4.avantas.com


  echo
  echo "## Generate the orderer msp"
  echo
  set -x
	fabric-ca-client enroll -u https://orderer4:orderer4pw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer4.avantas.com/msp --csr.hosts orderer4.avantas.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/avantas.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer4.avantas.com/msp/config.yaml


  echo
  echo "## Generate the orderer-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer4:orderer4pw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer4.avantas.com/tls --enrollment.profile tls --csr.hosts orderer4.avantas.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer4.avantas.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer4.avantas.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer4.avantas.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer4.avantas.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer4.avantas.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer4.avantas.com/tls/server.key

  mkdir ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer4.avantas.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer4.avantas.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer4.avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem

  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer4.avantas.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem

# Orderer 5

 echo
	echo "Register orderer5"
  echo
  set -x
	fabric-ca-client register --caname ca-orderer --id.name orderer5 --id.secret orderer5pw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

  mkdir -p organizations/ordererOrganizations/avantas.com/orderers/orderer5.avantas.com


  echo
  echo "## Generate the orderer msp"
  echo
  set -x
	fabric-ca-client enroll -u https://orderer5:orderer5pw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer5.avantas.com/msp --csr.hosts orderer5.avantas.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/avantas.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer5.avantas.com/msp/config.yaml


  echo
  echo "## Generate the orderer-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer5:orderer5pw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer5.avantas.com/tls --enrollment.profile tls --csr.hosts orderer5.avantas.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer5.avantas.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer5.avantas.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer5.avantas.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer5.avantas.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer5.avantas.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer5.avantas.com/tls/server.key

  mkdir ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer5.avantas.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer5.avantas.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer5.avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem

  cp ${PWD}/organizations/ordererOrganizations/avantas.com/orderers/orderer5.avantas.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/avantas.com/msp/tlscacerts/tlsca.avantas.com-cert.pem

}
