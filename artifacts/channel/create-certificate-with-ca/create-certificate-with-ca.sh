createcertificatesForProvedor() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p crypto-config-ca/peerOrganizations/provedor.labenv.com/
  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca.provedor.labenv.com --tls.certfiles ${PWD}/fabric-ca/provedor/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-provedor-labenv-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-provedor-labenv-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-provedor-labenv-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-provedor-labenv-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
  fabric-ca-client register --caname ca.provedor.labenv.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/provedor/tls-cert.pem

  echo
  echo "Register peer1"
  echo
  fabric-ca-client register --caname ca.provedor.labenv.com --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/provedor/tls-cert.pem

  echo
  echo "Register user"
  echo
  fabric-ca-client register --caname ca.provedor.labenv.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/provedor/tls-cert.pem

  echo
  echo "Register the org admin"
  echo
  fabric-ca-client register --caname ca.provedor.labenv.com --id.name provedoradmin --id.secret provedoradminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/provedor/tls-cert.pem

  mkdir -p crypto-config-ca/peerOrganizations/provedor.labenv.com/peers

  # -----------------------------------------------------------------------------------
  #  Peer 0
  mkdir -p crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer0.provedor.labenv.com

  echo
  echo "## Generate the peer0 msp"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.provedor.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer0.provedor.labenv.com/msp --csr.hosts peer0.provedor.labenv.com --tls.certfiles ${PWD}/fabric-ca/provedor/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer0.provedor.labenv.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.provedor.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer0.provedor.labenv.com/tls --enrollment.profile tls --csr.hosts peer0.provedor.labenv.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/provedor/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer0.provedor.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer0.provedor.labenv.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer0.provedor.labenv.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer0.provedor.labenv.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer0.provedor.labenv.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer0.provedor.labenv.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer0.provedor.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/tlsca
  cp ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer0.provedor.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/tlsca/tlsca.provedor.labenv.com-cert.pem

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/ca
  cp ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer0.provedor.labenv.com/msp/cacerts/* ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/ca/ca.provedor.labenv.com-cert.pem

  # ------------------------------------------------------------------------------------------------

  # Peer1

  mkdir -p crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer1.provedor.labenv.com

  echo
  echo "## Generate the peer1 msp"
  echo
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca.provedor.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer1.provedor.labenv.com/msp --csr.hosts peer1.provedor.labenv.com --tls.certfiles ${PWD}/fabric-ca/provedor/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer1.provedor.labenv.com/msp/config.yaml

  echo
  echo "## Generate the peer1-tls certificates"
  echo
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca.provedor.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer1.provedor.labenv.com/tls --enrollment.profile tls --csr.hosts peer1.provedor.labenv.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/provedor/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer1.provedor.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer1.provedor.labenv.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer1.provedor.labenv.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer1.provedor.labenv.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer1.provedor.labenv.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/peers/peer1.provedor.labenv.com/tls/server.key

  # --------------------------------------------------------------------------------------------------

  mkdir -p crypto-config-ca/peerOrganizations/provedor.labenv.com/users
  mkdir -p crypto-config-ca/peerOrganizations/provedor.labenv.com/users/User1@provedor.labenv.com

  echo
  echo "## Generate the user msp"
  echo
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca.provedor.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/users/User1@provedor.labenv.com/msp --tls.certfiles ${PWD}/fabric-ca/provedor/tls-cert.pem

  mkdir -p crypto-config-ca/peerOrganizations/provedor.labenv.com/users/Admin@provedor.labenv.com

  echo
  echo "## Generate the org admin msp"
  echo
  fabric-ca-client enroll -u https://provedoradmin:provedoradminpw@localhost:7054 --caname ca.provedor.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/users/Admin@provedor.labenv.com/msp --tls.certfiles ${PWD}/fabric-ca/provedor/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/provedor.labenv.com/users/Admin@provedor.labenv.com/msp/config.yaml

}

# createcertificatesForprovedor

createCertificateForDesenvolvedor() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p /crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca.desenvolvedor.labenv.com --tls.certfiles ${PWD}/fabric-ca/desenvolvedor/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-desenvolvedor-labenv-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-desenvolvedor-labenv-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-desenvolvedor-labenv-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-desenvolvedor-labenv-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
   
  fabric-ca-client register --caname ca.desenvolvedor.labenv.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/desenvolvedor/tls-cert.pem
   

  echo
  echo "Register peer1"
  echo
   
  fabric-ca-client register --caname ca.desenvolvedor.labenv.com --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/desenvolvedor/tls-cert.pem
   

  echo
  echo "Register user"
  echo
   
  fabric-ca-client register --caname ca.desenvolvedor.labenv.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/desenvolvedor/tls-cert.pem
   

  echo
  echo "Register the org admin"
  echo
   
  fabric-ca-client register --caname ca.desenvolvedor.labenv.com --id.name desenvolvedoradmin --id.secret desenvolvedoradminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/desenvolvedor/tls-cert.pem
   

  mkdir -p crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers
  mkdir -p crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer0.desenvolvedor.labenv.com

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.desenvolvedor.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer0.desenvolvedor.labenv.com/msp --csr.hosts peer0.desenvolvedor.labenv.com --tls.certfiles ${PWD}/fabric-ca/desenvolvedor/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer0.desenvolvedor.labenv.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.desenvolvedor.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer0.desenvolvedor.labenv.com/tls --enrollment.profile tls --csr.hosts peer0.desenvolvedor.labenv.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/desenvolvedor/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer0.desenvolvedor.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer0.desenvolvedor.labenv.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer0.desenvolvedor.labenv.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer0.desenvolvedor.labenv.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer0.desenvolvedor.labenv.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer0.desenvolvedor.labenv.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer0.desenvolvedor.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/tlsca
  cp ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer0.desenvolvedor.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/tlsca/tlsca.desenvolvedor.labenv.com-cert.pem

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/ca
  cp ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer0.desenvolvedor.labenv.com/msp/cacerts/* ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/ca/ca.desenvolvedor.labenv.com-cert.pem

  # --------------------------------------------------------------------------------
  #  Peer 1
  echo
  echo "## Generate the peer1 msp"
  echo
   
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca.desenvolvedor.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer1.desenvolvedor.labenv.com/msp --csr.hosts peer1.desenvolvedor.labenv.com --tls.certfiles ${PWD}/fabric-ca/desenvolvedor/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer1.desenvolvedor.labenv.com/msp/config.yaml

  echo
  echo "## Generate the peer1-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca.desenvolvedor.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer1.desenvolvedor.labenv.com/tls --enrollment.profile tls --csr.hosts peer1.desenvolvedor.labenv.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/desenvolvedor/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer1.desenvolvedor.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer1.desenvolvedor.labenv.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer1.desenvolvedor.labenv.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer1.desenvolvedor.labenv.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer1.desenvolvedor.labenv.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/peers/peer1.desenvolvedor.labenv.com/tls/server.key
  # -----------------------------------------------------------------------------------

  mkdir -p crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/users
  mkdir -p crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/users/User1@desenvolvedor.labenv.com

  echo
  echo "## Generate the user msp"
  echo
   
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca.desenvolvedor.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/users/User1@desenvolvedor.labenv.com/msp --tls.certfiles ${PWD}/fabric-ca/desenvolvedor/tls-cert.pem
   

  mkdir -p crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/users/Admin@desenvolvedor.labenv.com

  echo
  echo "## Generate the org admin msp"
  echo
   
  fabric-ca-client enroll -u https://desenvolvedoradmin:desenvolvedoradminpw@localhost:8054 --caname ca.desenvolvedor.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/users/Admin@desenvolvedor.labenv.com/msp --tls.certfiles ${PWD}/fabric-ca/desenvolvedor/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/desenvolvedor.labenv.com/users/Admin@desenvolvedor.labenv.com/msp/config.yaml

}

# createCertificateFordesenvolvedor

createCertificateForUsuario() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p /crypto-config-ca/peerOrganizations/usuario.labenv.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca.usuario.labenv.com --tls.certfiles ${PWD}/fabric-ca/usuario/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-usuario-labenv-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-usuario-labenv-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-usuario-labenv-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-usuario-labenv-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
   
  fabric-ca-client register --caname ca.usuario.labenv.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/usuario/tls-cert.pem
   

  echo
  echo "Register peer1"
  echo
   
  fabric-ca-client register --caname ca.usuario.labenv.com --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/usuario/tls-cert.pem
   

  echo
  echo "Register user"
  echo
   
  fabric-ca-client register --caname ca.usuario.labenv.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/usuario/tls-cert.pem
   

  echo
  echo "Register the org admin"
  echo
   
  fabric-ca-client register --caname ca.usuario.labenv.com --id.name usuarioadmin --id.secret usuarioadminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/usuario/tls-cert.pem
   

  mkdir -p crypto-config-ca/peerOrganizations/usuario.labenv.com/peers
  mkdir -p crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer0.usuario.labenv.com

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.usuario.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer0.usuario.labenv.com/msp --csr.hosts peer0.usuario.labenv.com --tls.certfiles ${PWD}/fabric-ca/usuario/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer0.usuario.labenv.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.usuario.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer0.usuario.labenv.com/tls --enrollment.profile tls --csr.hosts peer0.usuario.labenv.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/usuario/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer0.usuario.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer0.usuario.labenv.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer0.usuario.labenv.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer0.usuario.labenv.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer0.usuario.labenv.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer0.usuario.labenv.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer0.usuario.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/tlsca
  cp ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer0.usuario.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/tlsca/tlsca.usuario.labenv.com-cert.pem

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/ca
  cp ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer0.usuario.labenv.com/msp/cacerts/* ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/ca/ca.usuario.labenv.com-cert.pem

  # --------------------------------------------------------------------------------
  #  Peer 1
  echo
  echo "## Generate the peer1 msp"
  echo
   
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca.usuario.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer1.usuario.labenv.com/msp --csr.hosts peer1.usuario.labenv.com --tls.certfiles ${PWD}/fabric-ca/usuario/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer1.usuario.labenv.com/msp/config.yaml

  echo
  echo "## Generate the peer1-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca.usuario.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer1.usuario.labenv.com/tls --enrollment.profile tls --csr.hosts peer1.usuario.labenv.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/usuario/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer1.usuario.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer1.usuario.labenv.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer1.usuario.labenv.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer1.usuario.labenv.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer1.usuario.labenv.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/peers/peer1.usuario.labenv.com/tls/server.key
  # -----------------------------------------------------------------------------------

  mkdir -p crypto-config-ca/peerOrganizations/usuario.labenv.com/users
  mkdir -p crypto-config-ca/peerOrganizations/usuario.labenv.com/users/User1@usuario.labenv.com

  echo
  echo "## Generate the user msp"
  echo
   
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca.usuario.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/users/User1@usuario.labenv.com/msp --tls.certfiles ${PWD}/fabric-ca/usuario/tls-cert.pem
   

  mkdir -p crypto-config-ca/peerOrganizations/usuario.labenv.com/users/Admin@usuario.labenv.com

  echo
  echo "## Generate the org admin msp"
  echo
   
  fabric-ca-client enroll -u https://usuarioadmin:usuarioadminpw@localhost:8054 --caname ca.usuario.labenv.com -M ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/users/Admin@usuario.labenv.com/msp --tls.certfiles ${PWD}/fabric-ca/usuario/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/usuario.labenv.com/users/Admin@usuario.labenv.com/msp/config.yaml

}

createCretificateForOrderer() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p crypto-config-ca/ordererOrganizations/labenv.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config-ca/ordererOrganizations/labenv.com

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

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
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/msp/config.yaml

  echo
  echo "Register orderer"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register orderer2"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer2 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register orderer3"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer3 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register the orderer admin"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  mkdir -p crypto-config-ca/ordererOrganizations/labenv.com/orderers
  # mkdir -p crypto-config-ca/ordererOrganizations/labenv.com/orderers/labenv.com

  # ---------------------------------------------------------------------------
  #  Orderer

  mkdir -p crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer.labenv.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/msp --csr.hosts orderer.labenv.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/tls --enrollment.profile tls --csr.hosts orderer.labenv.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/tls/signcerts/* ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/tls/keystore/* ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/msp/tlscacerts/tlsca.labenv.com-cert.pem

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/msp/tlscacerts/tlsca.labenv.com-cert.pem

  # -----------------------------------------------------------------------
  #  Orderer 2

  mkdir -p crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer2.labenv.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer2.labenv.com/msp --csr.hosts orderer2.labenv.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer2.labenv.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer2.labenv.com/tls --enrollment.profile tls --csr.hosts orderer2.labenv.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer2.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer2.labenv.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer2.labenv.com/tls/signcerts/* ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer2.labenv.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer2.labenv.com/tls/keystore/* ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer2.labenv.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer2.labenv.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer2.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer2.labenv.com/msp/tlscacerts/tlsca.labenv.com-cert.pem

  # mkdir ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/msp/tlscacerts
  # cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer2.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/msp/tlscacerts/tlsca.labenv.com-cert.pem

  # ---------------------------------------------------------------------------
  #  Orderer 3
  mkdir -p crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer3.labenv.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer3.labenv.com/msp --csr.hosts orderer3.labenv.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer3.labenv.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer3.labenv.com/tls --enrollment.profile tls --csr.hosts orderer3.labenv.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer3.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer3.labenv.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer3.labenv.com/tls/signcerts/* ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer3.labenv.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer3.labenv.com/tls/keystore/* ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer3.labenv.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer3.labenv.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer3.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer3.labenv.com/msp/tlscacerts/tlsca.labenv.com-cert.pem

  # mkdir ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/msp/tlscacerts
  # cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/orderers/orderer3.labenv.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/msp/tlscacerts/tlsca.labenv.com-cert.pem

  # ---------------------------------------------------------------------------

  mkdir -p crypto-config-ca/ordererOrganizations/labenv.com/users
  mkdir -p crypto-config-ca/ordererOrganizations/labenv.com/users/Admin@labenv.com

  echo
  echo "## Generate the admin msp"
  echo
   
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/users/Admin@labenv.com/msp --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/labenv.com/users/Admin@labenv.com/msp/config.yaml

}

# createCretificateForOrderer

sudo rm -rf crypto-config-ca/*
# sudo rm -rf fabric-ca/*
createcertificatesForprovedor
createCertificateFordesenvolvedor
createCretificateForOrderer

