'use strict';

const { Gateway, Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');


const userRegister = "org1_department1_user_1955"

async function main() {
    try {
        // load the network configuration
        const ccpPath = path.resolve(__dirname, '..', '..', 'hyperledger-fabric-2.0', 'organizations', 'peerOrganizations', 'org1.sample.com', 'connection-org1.json');
        let ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet/org1');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        const identity = await wallet.get(userRegister);
        if (!identity) {
            console.log('An identity for the user ' +  userRegister + ' does not exist in the wallet');
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, { wallet, identity: userRegister, discovery: { enabled: true, asLocalhost: true } });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork('mychannel');

        // https://hyperledger.github.io/fabric-sdk-node/release-2.2/module-fabric-network.html#.BlockListener
        const listenerBlockEvent = async (event) => {
            var blockNum = event.blockNumber
            console.log('Block Number: ' + blockNum);

            var blockDataPayload = event.blockData.data.data[0].payload
            console.log('Block Data Payload: ' + JSON.stringify(blockDataPayload));

        }
        const options = {
        };
        await network.addBlockListener(listenerBlockEvent, options);


        // Get the contract from the network.
        const contract = network.getContract('nft'); 

        // https://hyperledger.github.io/fabric-sdk-node/release-2.2/module-fabric-network.Contract.html#addContractListener
        const listener = async (event) => {
            if (event.eventName === 'CreateEvent') {
                var details = event.payload.toString('utf8');     
                details = JSON.parse(details)
 
                // eg. {"Code":"0","EventName":"CreateEvent","TxId":"09d21ddd5ab977e1dcce0159a4c96b7902adf3fef293870a90d282f0efd7fcda","ItemId":"","SymbolId":"symbol-779","Description":"Create Token Successfully"}
                console.log('Create Event Listener: ' + JSON.stringify(details));
            }else if (event.eventName === 'GetTokenEvent') {
                var details = event.payload.toString('utf8');    
                details = JSON.parse(details)

                console.log('GetToken Event Listener: ' + JSON.stringify(details));
            }else if (event.eventName === 'GetItemEvent') {
                var details = event.payload.toString('utf8');    
                details = JSON.parse(details)
 
                console.log('GetItem Event Listener: ' + JSON.stringify(details));
            }else if (event.eventName === 'MintEvent') {
                var details = event.payload.toString('utf8');    
                details = JSON.parse(details)
 
                // eg. {"Code":"0","EventName":"MintEvent","TxId":"225622b9f5292b7b8271afea16d32f413a974a54d74d4c54b56246a1fc7e33b1","ItemId":"116-b-b-ITEM","SymbolId":"","Description":"Mint Item Successfully"}
                console.log('Mint-item Event Listener: ' + JSON.stringify(details));
            }else if (event.eventName === 'BurnEvent') {
                var details = event.payload.toString('utf8');    
                details = JSON.parse(details)
 
                // eg. {"Code":"0","EventName":"BurnEvent","TxId":"c6e72533a70e9d2d6db8af5aa1a722a057023b1f34899ccfd7b28a7e6734eda0","ItemId":"116-b-b-ITEM","SymbolId":"symbol-779","Description":"Burn Item Successfully"}
                console.log('Burn-item Event Listener: ' + JSON.stringify(details));
            }else if (event.eventName === 'TransferEvent') {
                var details = event.payload.toString('utf8');    
                details = JSON.parse(details)
 
                // eg. {"Code":"0","EventName":"TransferEvent","TxId":"a8b279a112c873d115569588889e96f2245586dee1a5d444500b9f3fb9e187b6","ItemId":"116-b-b-ITEM","SymbolId":"","Description":"Transfer Item Successfully"}
                console.log('Transfer-item Event Listener: ' + JSON.stringify(details));
            }else if (event.eventName === 'EndorseEvent') {
                var details = event.payload.toString('utf8');    
                details = JSON.parse(details)
 
                // eg. {"Code":"0","EventName":"EndorseEvent","TxId":"e0d1421b12a78efa46a765d6de321d83ab87a93af26f6362c4779ef638aa154f","ItemId":"116-b-b-ITEM","SymbolId":"symbol-779","Description":"Endorsed Item Successfully"}
                console.log('Endorse-item Event Listener: ' + JSON.stringify(details));
            }else if (event.eventName === 'UpdateItemMetadataEvent') {
                var details = event.payload.toString('utf8');    
                details = JSON.parse(details)
 
                // eg. {"Code":"0","EventName":"UpdateItemMetadataEvent","TxId":"4298847a33a3dc4c0812665ac5ef641ba007cf2547b9f5b13aa8336346f9659e","ItemId":"779-ITEM","SymbolId":"symbol-779","Description":"Update Item Metadata Successfully"}
                console.log('Update-item-Metadata Event Listener: ' + JSON.stringify(details));
            }

        };
        await contract.addContractListener(listener);
       
        //==================================================================

        //// 1. Create-token : name, symbols, metadata, totalSupplys
        ///{"Args":["create","symbol57_name","symbol57","metadata_123456789","3"]}
        // var returnvalue_create = await contract.submitTransaction('create','symbol-889_name','symbol-889','metadata_123456789','11');  
        // console.log('\nTransaction has been submitted' + returnvalue_create);

        //option-2 : Create token
        // const transaction = contract.createTransaction('create');
        // await transaction.submit("symbol-1991_name","symbol-1991","metadata_123456789","13");
        // console.log('\nTransaction has been submitted' + returnvalue_create);
        
        ////1.1  '{"Args":["getToken","symbol57"]}'
        // var returnvalue_getToken =  await contract.evaluateTransaction('getToken', 'symbol-779');
        // console.log('\nTransaction has been evaluated for GETTOKEN : ' + returnvalue_getToken);

        // ////2. Mint-item : symbols, owner, itemId, properties, metadata
        // '{"Args":["mint","symbol57", "alice111", "57-ITEM", "properties: 57-ITEM", "metadata: 57-ITEM"]}'
        // var returnvalue_mint = await contract.submitTransaction('mint','symbol-779', 'org1_department1_user_1950', '779-ITEM', 'properties: xxxx-ITEM', 'metadata: xxxx-ITEM');    
        // console.log('\nTransaction has been submitted' + returnvalue_mint);

        // // ////2.1  '{"Args":["getItem","symbol57", "57-ITEM"]}'
        // var returnvalue_getItem = await contract.evaluateTransaction('getItem', 'symbol-779', '779-ITEM');
        // console.log('\nTransaction has been evaluated for GETITEM: ' + returnvalue_getItem);

        // // ////3. Endorse : {'Args':['endorse', 'symbol-779', '779-ITEM']}'
        // var returnvalue_endorse = await contract.submitTransaction('endorse', 'symbol-779', '779-ITEM', 'remarks: endorsed by XXX 2nd-time');
        // console.log('\nTransaction has been submitted for ENDORSE: ' + returnvalue_endorse);

        // // ////4.  '{'Args':['getItem', 'symbol-779', '779-ITEM']}'
        // var returnvalue_getItem = await contract.evaluateTransaction('getItem', 'symbol-779', '779-ITEM');
        // console.log('\nTransaction has been evaluated for GETITEM: ' + returnvalue_getItem);

        // //5. Transfer-item: '{'Args':['transfer', 'symbol-779', 'alice11', 'bob', '779-ITEM']}'
        // var returnvalue_transfer = await contract.submitTransaction('transfer', 'symbol-779', 'alice111', 'bob', '779-ITEM');
        // console.log('\nTransaction has been submitted for TRANSFER: ' + returnvalue_transfer);

        // //5.2  '{'Args':['getItem', 'symbol-779', '779-ITEM']}'
        // var returnvalue_getItem =  await contract.evaluateTransaction('getItem', 'symbol-779', '779-ITEM');
        // console.log('\nTransaction has been evaluated for GETITEM : ' + returnvalue_getItem);
 
        // //6. Burn-item : '{'Args':['burn', 'symbol-779',  'bob', '779-ITEM']}'
        // var returnvalue_burn = await contract.submitTransaction('burn', 'symbol-779',  'bob', '779-ITEM');
        // console.log('\nTransaction has been submitted for BURN: ' + returnvalue_burn);

        // //7.  '{'Args':['getItem', 'symbol-779', '779-ITEM']}'
        // var returnvalue_getItem =  await contract.evaluateTransaction('getItem', 'symbol-779', '779-ITEM');
        // console.log('\nTransaction has been evaluated for GETITEM : ' + returnvalue_getItem);


        // Disconnect from the gateway.
        await gateway.disconnect();

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

main();
