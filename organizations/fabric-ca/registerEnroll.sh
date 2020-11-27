
function createOrg1 {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/org1.sample.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.sample.com/

  set -x
  fabric-ca-client enroll -u https://org1_owner:org1_ownerpw@localhost:7054 --caname ca-org1 --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
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
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/org1.sample.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-org1 --id.name org1_department1_head --id.secret org1_department1_headpw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-org1 --id.name org1_department1_user101 --id.secret org1_department1_user101pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-org1 --id.name org1_hr --id.secret org1_hrpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/org1.sample.com/peers
  mkdir -p organizations/peerOrganizations/org1.sample.com/peers/peer0.org1.sample.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://org1_department1_head:org1_department1_headpw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.sample.com/peers/peer0.org1.sample.com/msp --csr.hosts peer0.org1.sample.com --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org1.sample.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.sample.com/peers/peer0.org1.sample.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://org1_department1_head:org1_department1_headpw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.sample.com/peers/peer0.org1.sample.com/tls --enrollment.profile tls --csr.hosts peer0.org1.sample.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/org1.sample.com/peers/peer0.org1.sample.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.sample.com/peers/peer0.org1.sample.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org1.sample.com/peers/peer0.org1.sample.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org1.sample.com/peers/peer0.org1.sample.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org1.sample.com/peers/peer0.org1.sample.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org1.sample.com/peers/peer0.org1.sample.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/org1.sample.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org1.sample.com/peers/peer0.org1.sample.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.sample.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/org1.sample.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org1.sample.com/peers/peer0.org1.sample.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.sample.com/tlsca/tlsca.org1.sample.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/org1.sample.com/ca
  cp ${PWD}/organizations/peerOrganizations/org1.sample.com/peers/peer0.org1.sample.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org1.sample.com/ca/ca.org1.sample.com-cert.pem

  mkdir -p organizations/peerOrganizations/org1.sample.com/users
  mkdir -p organizations/peerOrganizations/org1.sample.com/users/Org1_department1_user101@org1.sample.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://org1_department1_user101:org1_department1_user101pw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.sample.com/users/Org1_department1_user101@org1.sample.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  mkdir -p organizations/peerOrganizations/org1.sample.com/users/Org1_hr@org1.sample.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://org1_hr:org1_hrpw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.sample.com/users/Org1_hr@org1.sample.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org1.sample.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.sample.com/users/Org1_hr@org1.sample.com/msp/config.yaml

}


function createOrg2 {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/org2.sample.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org2.sample.com/

  set -x
  fabric-ca-client enroll -u https://org2_owner:org2_ownerpw@localhost:8054 --caname ca-org2 --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
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
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/org2.sample.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-org2 --id.name org2_department1_head --id.secret org2_department1_headpw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-org2 --id.name org2_department1_user101 --id.secret org2_department1_user101pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-org2 --id.name org2_hr --id.secret org2_hrpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/org2.sample.com/peers
  mkdir -p organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://org2_department1_head:org2_department1_headpw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/msp --csr.hosts peer0.org2.sample.com --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org2.sample.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://org2_department1_head:org2_department1_headpw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/tls --enrollment.profile tls --csr.hosts peer0.org2.sample.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/org2.sample.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.sample.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/org2.sample.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.sample.com/tlsca/tlsca.org2.sample.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/org2.sample.com/ca
  cp ${PWD}/organizations/peerOrganizations/org2.sample.com/peers/peer0.org2.sample.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org2.sample.com/ca/ca.org2.sample.com-cert.pem

  mkdir -p organizations/peerOrganizations/org2.sample.com/users
  mkdir -p organizations/peerOrganizations/org2.sample.com/users/User1@org2.sample.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://org2_department1_user101:org2_department1_user101pw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.sample.com/users/Org2_department1_user101@org2.sample.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  mkdir -p organizations/peerOrganizations/org2.sample.com/users/Org2_hr@org2.sample.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://org2_hr:org2_hrpw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.sample.com/users/Org2_hr@org2.sample.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org2.sample.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.sample.com/users/Org2_hr@org2.sample.com/msp/config.yaml

}

function createOrderer {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/ordererOrganizations/sample.com

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/sample.com

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
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/ordererOrganizations/sample.com/msp/config.yaml

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

	mkdir -p organizations/ordererOrganizations/sample.com/orderers
  mkdir -p organizations/ordererOrganizations/sample.com/orderers/sample.com

  mkdir -p organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com

  echo
  echo "## Generate the orderer msp"
  echo
  set -x
	fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/msp --csr.hosts orderer.sample.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/sample.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/tls --enrollment.profile tls --csr.hosts orderer.sample.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/tls/server.key

  mkdir ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/msp/tlscacerts/tlsca.sample.com-cert.pem

  mkdir ${PWD}/organizations/ordererOrganizations/sample.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer.sample.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/sample.com/msp/tlscacerts/tlsca.sample.com-cert.pem

  mkdir -p organizations/ordererOrganizations/sample.com/users
  mkdir -p organizations/ordererOrganizations/sample.com/users/Admin@sample.com

  echo
  echo "## Generate the admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/sample.com/users/Admin@sample.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/sample.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/sample.com/users/Admin@sample.com/msp/config.yaml

# orderer 2

echo
	echo "Register orderer2"
  echo
  set -x
	fabric-ca-client register --caname ca-orderer --id.name orderer2 --id.secret orderer2pw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

  mkdir -p organizations/ordererOrganizations/sample.com/orderers/orderer2.sample.com


  echo
  echo "## Generate the orderer msp"
  echo
  set -x
	fabric-ca-client enroll -u https://orderer2:orderer2pw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer2.sample.com/msp --csr.hosts orderer2.sample.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/sample.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer2.sample.com/msp/config.yaml


  echo
  echo "## Generate the orderer-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer2:orderer2pw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer2.sample.com/tls --enrollment.profile tls --csr.hosts orderer2.sample.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer2.sample.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer2.sample.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer2.sample.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer2.sample.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer2.sample.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer2.sample.com/tls/server.key

  mkdir ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer2.sample.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer2.sample.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer2.sample.com/msp/tlscacerts/tlsca.sample.com-cert.pem

  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer2.sample.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/sample.com/msp/tlscacerts/tlsca.sample.com-cert.pem

# orderer3

echo
	echo "Register orderer3"
  echo
  set -x
	fabric-ca-client register --caname ca-orderer --id.name orderer3 --id.secret orderer3pw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

  mkdir -p organizations/ordererOrganizations/sample.com/orderers/orderer3.sample.com


  echo
  echo "## Generate the orderer msp"
  echo
  set -x
	fabric-ca-client enroll -u https://orderer3:orderer3pw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer3.sample.com/msp --csr.hosts orderer3.sample.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/sample.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer3.sample.com/msp/config.yaml


  echo
  echo "## Generate the orderer-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer3:orderer3pw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer3.sample.com/tls --enrollment.profile tls --csr.hosts orderer3.sample.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer3.sample.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer3.sample.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer3.sample.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer3.sample.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer3.sample.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer3.sample.com/tls/server.key

  mkdir ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer3.sample.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer3.sample.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer3.sample.com/msp/tlscacerts/tlsca.sample.com-cert.pem

  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer3.sample.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/sample.com/msp/tlscacerts/tlsca.sample.com-cert.pem

 # Ordrer 4

 echo
	echo "Register orderer4"
  echo
  set -x
	fabric-ca-client register --caname ca-orderer --id.name orderer4 --id.secret orderer4pw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

  mkdir -p organizations/ordererOrganizations/sample.com/orderers/orderer4.sample.com


  echo
  echo "## Generate the orderer msp"
  echo
  set -x
	fabric-ca-client enroll -u https://orderer4:orderer4pw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer4.sample.com/msp --csr.hosts orderer4.sample.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/sample.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer4.sample.com/msp/config.yaml


  echo
  echo "## Generate the orderer-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer4:orderer4pw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer4.sample.com/tls --enrollment.profile tls --csr.hosts orderer4.sample.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer4.sample.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer4.sample.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer4.sample.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer4.sample.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer4.sample.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer4.sample.com/tls/server.key

  mkdir ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer4.sample.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer4.sample.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer4.sample.com/msp/tlscacerts/tlsca.sample.com-cert.pem

  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer4.sample.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/sample.com/msp/tlscacerts/tlsca.sample.com-cert.pem

# Orderer 5

 echo
	echo "Register orderer5"
  echo
  set -x
	fabric-ca-client register --caname ca-orderer --id.name orderer5 --id.secret orderer5pw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

  mkdir -p organizations/ordererOrganizations/sample.com/orderers/orderer5.sample.com


  echo
  echo "## Generate the orderer msp"
  echo
  set -x
	fabric-ca-client enroll -u https://orderer5:orderer5pw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer5.sample.com/msp --csr.hosts orderer5.sample.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/sample.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer5.sample.com/msp/config.yaml


  echo
  echo "## Generate the orderer-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer5:orderer5pw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer5.sample.com/tls --enrollment.profile tls --csr.hosts orderer5.sample.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer5.sample.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer5.sample.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer5.sample.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer5.sample.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer5.sample.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer5.sample.com/tls/server.key

  mkdir ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer5.sample.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer5.sample.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer5.sample.com/msp/tlscacerts/tlsca.sample.com-cert.pem

  cp ${PWD}/organizations/ordererOrganizations/sample.com/orderers/orderer5.sample.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/sample.com/msp/tlscacerts/tlsca.sample.com-cert.pem

}
