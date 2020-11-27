/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Wallets } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const fs = require('fs');
const path = require('path');


const userRegister_adminRole = "org2_department1_user"                       
const enrollAdmin = "org2_owner"                            // ** Only this 'org2_owner' can do the user-registered


async function main() {
    try {
        // load the network configuration
        const ccpPath = path.resolve(__dirname, '..', '..', 'hyperledger-fabric-2.0', 'organizations', 'peerOrganizations', 'org2.sample.com', 'connection-org2.json');
        const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new CA client for interacting with the CA.
        const caURL = ccp.certificateAuthorities['ca.org2.sample.com'].url;
        const ca = new FabricCAServices(caURL);

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet/org2');
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
            affiliation: 'org2.department1',
            enrollmentID: userRegister_adminRole,
            role: 'admin',         // eg. client, admin
            attrs: [{ name: "roletype", value: "admin", ecert: true }]       // Role: admin

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
            mspId: 'org2MSP',
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
