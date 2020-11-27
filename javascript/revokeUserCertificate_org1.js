/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const FabricCAServices = require('fabric-ca-client');
const { Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');

async function main() {
    try {
        // load the network configuration
        const ccpPath = path.resolve(__dirname, '..', '..', 'hyperledger-fabric-2.0', 'organizations', 'peerOrganizations', 'org1.sample.com', 'connection-org1.json');
        const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new CA client for interacting with the CA.
        const caURL = ccp.certificateAuthorities['ca.org1.sample.com'].url;
        const ca = new FabricCAServices(caURL);

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet/org1');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // 1. Revoke
        let admin_registrar = new User('org1_ownerXXXX');          
        const revoke = await ca.revoke({enrollmentID: 'org1_department1_user'}, admin_registrar);

        console.log('Successfully revoke ' + 'org1_department1_user' + ' user with the request for attributes');


    } catch (error) {
        console.error(`Failed to revoke user : ${error}`);          // Error Message: 'Failed to enroll user : ReferenceError: User is not defined'
        process.exit(1);
    }
}

main();
