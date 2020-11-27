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

        // 1. Re-Enroll
        let user = new User('admin');          
        const enrollment = await ca.reenroll(user, [{name: 'myattrib', require: true}]);
        const x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: 'Org1MSP',
            type: 'X.509',
        };
        await wallet.put(user, x509Identity);
        console.log('Successfully re-enrolled ' + user + ' user with the request for attributes');


    } catch (error) {
        console.error(`Failed to enroll user : ${error}`);          // Error Message: 'Failed to enroll user : ReferenceError: User is not defined'
        process.exit(1);
    }
}

main();
