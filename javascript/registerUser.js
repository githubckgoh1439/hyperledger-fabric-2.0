/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Wallets } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const fs = require('fs');
const path = require('path');

// const userRegister_clientRole = "org1-client-AB1122"       // user as client-role
const userRegister_adminRole = "appUser2"                       // user as admin-role
const enrollAdmin = "admin"

async function main() {
    try {
        // load the network configuration
        const ccpPath = path.resolve(__dirname, '..', '..', 'hyperledger-fabric-2.0', 'organizations', 'peerOrganizations', 'org1.avantas.com', 'connection-org1.json');
        const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new CA client for interacting with the CA.
        const caURL = ccp.certificateAuthorities['ca.org1.avantas.com'].url;
        const ca = new FabricCAServices(caURL);

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        const userIdentity = await wallet.get(userRegister_adminRole);
        if (userIdentity) {
            console.log('An identity for the user ' + userRegister_adminRole + ' already exists in the wallet');
            return;
        }

        // Check to see if we've already enrolled the admin user.
        const adminIdentity = await wallet.get(enrollAdmin);
        if (!adminIdentity) {
            console.log('An identity for the admin user "admin" does not exist in the wallet');
            console.log('Run the enrollAdmin.js application before retrying');
            return;
        }

        // build a user object for authenticating with the CA
        const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
        const adminUser = await provider.getUserContext(adminIdentity, enrollAdmin);

        // Register the user, enroll the user, and import the new identity into the wallet.
        const secret = await ca.register({
            affiliation: 'org1.department1',
            enrollmentID: userRegister_adminRole,
            role: 'admin',         // eg. client, admin
            attrs: [{ name: "roletype", value: "admin", ecert: true }]       // Role: admin
            // enrollmentID: userRegister_clientRole,
            // role: 'client',         // eg. client, admin
            // attrs: [{ name: "roletype", value: "client", ecert: true }]       // Role: non-admin

        }, adminUser);
        const enrollment = await ca.enroll({
            enrollmentID: userRegister_adminRole,
            enrollmentSecret: secret
        });
        const x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: 'Org1MSP',
            type: 'X.509',
        };
        await wallet.put(userRegister_adminRole, x509Identity);
        console.log('Successfully registered and enrolled admin user ' + userRegister_adminRole + ' and imported it into the wallet');

    } catch (error) {
        console.error(`Failed to register user ` + userRegister_adminRole + `: ${error}`);
        process.exit(1);
    }
}

main();
