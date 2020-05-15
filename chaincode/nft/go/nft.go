package main

import (
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// Define the Smart Contract structure
type NFTChainCode struct {
	contractapi.Contract
}

type NFT struct {
	Name        string
	Symbol      string
	Creator     string
	Metadata    string
	TotalSupply int
	Minted      int
}

// ItemID
type Item struct {
	ItemId       []byte
	Metadata     string
	Properties   string
	Endorsements []string
}

// responseMessage
type ResponseMessage struct {
	Code    string
	Message string
	Payload []string
}

// responseMessage
type EventListenerMessage struct {
	EventName   string
	TxId        string
	ItemId      string
	SymbolId    string
	Description string
}

type QueryResult struct {
	Key    string `json:"Key"`
	Record *NFT
}

// Init
func (s *NFTChainCode) InitLedger(ctx contractapi.TransactionContextInterface) error {
	fmt.Printf("\n============= START : Chaincode is instantiated by the blockchain network :===========")

	nft := []NFT{

		NFT{Name: "token0", Symbol: "symbol0", Creator: "blue", Metadata: "metadata_123456789", TotalSupply: 20000, Minted: 3},
		NFT{Name: "token1", Symbol: "symbol1", Creator: "red", Metadata: "metadata_123456789", TotalSupply: 30000, Minted: 3},
		NFT{Name: "token2", Symbol: "symbol2", Creator: "green", Metadata: "metadata_123456789", TotalSupply: 40000, Minted: 3},
		NFT{Name: "token3", Symbol: "symbol3", Creator: "yellow", Metadata: "metadata_123456789", TotalSupply: 50000, Minted: 3},
		NFT{Name: "token4", Symbol: "symbol4", Creator: "purple", Metadata: "metadata_123456789", TotalSupply: 60000, Minted: 3},
		NFT{Name: "token5", Symbol: "symbol5", Creator: "brown", Metadata: "metadata_123456789", TotalSupply: 70000, Minted: 3},
	}

	for _, nf := range nft {
		nftAsBytes, _ := json.Marshal(nf)
		fmt.Printf("\n============= START : Nft symbol :===========", nf.Symbol)
		err := ctx.GetStub().PutState(nf.Symbol, nftAsBytes)

		if err != nil {
			return fmt.Errorf("Failed to put to world state. %s", err.Error())
		}

	}
	return nil

}

// createToken
func (s *NFTChainCode) CreateNonFungibleToken(ctx contractapi.TransactionContextInterface, args []string) ([]byte, error) {

	if len(args) != 4 {
		code := "99"
		msg := "Incorrect number of arguments. Expecting 4"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}

	tokenName := args[0]
	tokenSymbol := args[1]
	tokenMetadata := args[2]
	tokenSupply, err := strconv.Atoi(args[3])
	if err != nil {

		code := "99"
		msg := "Invalid Total Supply: " + err.Error()
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}

	//1. Validation : Not authorised to apply for token creation.
	_, err = ctx.GetClientIdentity().GetMSPID() // get information about tx creator
	if err != nil {

		code := "99"
		msg := "Error while getting the signer: " + err.Error()
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}

	creator, err := ctx.GetClientIdentity().GetID()
	if err != nil {
		fmt.Printf("\nSigner : %v", (creator))
	}

	//2. Validation : Is this token-symbol existed ?

	if TokenExists(ctx, tokenSymbol) {
		code := "99"
		msg := "Symbol already existed"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}

	//3. Construct the Token Object, then save into blockchain
	token := &NFT{
		Name:        tokenName,
		Symbol:      tokenSymbol,
		Creator:     creator,
		Metadata:    tokenMetadata,
		TotalSupply: tokenSupply,
		Minted:      0,
	}
	tokenKey := tokenSymbol
	tokenData, _ := json.Marshal(token)
	err = ctx.GetStub().PutState(tokenKey, tokenData)
	if err != nil {

		code := "99"
		msg := "Failed to create token tx"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}
	fmt.Printf("\nFinal symbol : %v, Token Data : %v", tokenKey, string(tokenData))

	txID := ctx.GetStub().GetTxID()
	eventPayload := &EventListenerMessage{
		EventName:   "NonFungibleTokenEvent",
		TxId:        txID,
		ItemId:      "",
		SymbolId:    tokenSymbol,
		Description: "Create Token Successfully",
	}
	invokeEventlistener(ctx, eventPayload)

	code := "0"
	msg := "Create Token Successfully"
	payloads := []string{txID, creator}
	rsData := getResponseData(code, msg, payloads)
	return rsData, nil
}

// -- Chaincode Event Listener
func invokeEventlistener(ctx contractapi.TransactionContextInterface, event *EventListenerMessage) {

	PayloadData, _ := json.Marshal(event)
	err := ctx.GetStub().SetEvent(event.EventName, PayloadData)
	if err != nil {
		msg := "Failed event listener : " + err.Error()
		fmt.Printf("\n %v", msg)
		return
	}

	return
}

// mint
func (s *NFTChainCode) MintNonFungibleTokenItem(ctx contractapi.TransactionContextInterface, args []string) ([]byte, error) {
	err := ctx.GetClientIdentity().AssertAttributeValue("roletype", "admin")
	if err != nil {
		code := "99"
		msg := "Incorrect roletype attribute : " + err.Error()
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}

	if len(args) != 5 {

		code := "99"
		msg := "Incorrect number of arguments. Expecting 5"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}

	tokenSymbol := args[0]
	itemIDOwner := args[1] // who is the itemID-owner
	itemID := []byte(args[2])
	itemProperties := args[3]
	itemMetadata := args[4]

	//2. Validation : Is this token-symbol existed ?
	if TokenExists(ctx, tokenSymbol) == false {

		code := "99"
		msg := "Symbol not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}

	//3.1 Validation : Is this itemID existed ?
	if IsItemIDExisted(ctx, tokenSymbol, itemID) == true {

		code := "99"
		msg := "ItemID already exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}

	//3.2 Validation : '*NFT.Minted' <= '*NFT.TotalSupply', which can not exceed the total-supply
	tokenInfo, _ := ctx.GetStub().GetState(tokenSymbol)
	nft := NFT{}
	json.Unmarshal(tokenInfo, &nft)
	curTotalSupply := nft.TotalSupply
	curMinted := nft.Minted
	if curMinted >= curTotalSupply {

		code := "99"
		msg := "Exceed the limit of Total Supply. Not allowed to proceed"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil

	}

	//4. Create this new-token-item which is unique
	item := &Item{
		ItemId:     itemID,
		Properties: itemProperties,
		Metadata:   itemMetadata,
	}
	itemKey := getNonFungibleItemKey(tokenSymbol, itemID)
	itemData, _ := json.Marshal(item)
	ctx.GetStub().PutState(string(itemKey), itemData)

	//5. Assign this new-token-itemID to a receiver(owner)
	itemOwnerKey := getNonFungibleOwnerKey(tokenSymbol, itemID)
	ctx.GetStub().PutState(string(itemOwnerKey), []byte(itemIDOwner))

	//6. Update the '*NFT.Minted' += 1
	mintedAmt := 1
	changeTokenMintedAmount(ctx, tokenSymbol, mintedAmt)

	// getTxID
	txID := ctx.GetStub().GetTxID()
	eventPayload := &EventListenerMessage{
		EventName:   "NonFungibleTokenEvent",
		TxId:        txID,
		ItemId:      args[2],
		SymbolId:    "",
		Description: "Mint Item Successfully",
	}
	invokeEventlistener(ctx, eventPayload)

	code := "0"
	msg := "Mint Item Successfully"
	payloads := []string{txID}
	rsData := getResponseData(code, msg, payloads)

	return rsData, nil
}

// sub :  Update the '*NFT.Minted' += 1
func changeTokenMintedAmount(ctx contractapi.TransactionContextInterface, symbol string, minted int) {

	initTokenValue, _ := ctx.GetStub().GetState(symbol) // 先讀取
	nonFungibleToken := NFT{}
	json.Unmarshal(initTokenValue, &nonFungibleToken)

	// add new record - base on new-owner
	nonFungibleToken.Minted = nonFungibleToken.Minted + minted // 再修改, Update the 'minted' amount
	latestTokenValue, _ := json.Marshal(nonFungibleToken)
	ctx.GetStub().PutState(symbol, latestTokenValue) // 最後寫入

	return
}

// burn
func (s *NFTChainCode) BurnNonFungibleTokenItem(ctx contractapi.TransactionContextInterface, args []string) ([]byte, error) {

	if len(args) != 3 {
		code := "99"
		msg := "Incorrect number of arguments. Expecting 3"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil

	}

	tokenSymbol := args[0]
	itemIDOwner := args[1] // who is the itemID-owner
	itemID := []byte(args[2])

	//1. Validation : Is this token-symbol existed ?
	if TokenExists(ctx, tokenSymbol) == false {
		code := "99"
		msg := "Symbol not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil

	}

	//2. Validation : Is this itemID existed ?
	if IsItemIDExisted(ctx, tokenSymbol, itemID) == false {
		code := "99"
		msg := "ItemID not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}

	//4.1 : Get the info of : ownerKey, itemKey
	itemKey := getNonFungibleItemKey(tokenSymbol, itemID)
	itemOwnerKey := getNonFungibleOwnerKey(tokenSymbol, itemID)

	itemOwnerData, _ := ctx.GetStub().GetState(string(itemOwnerKey))

	// Validation : Is the item-owner matched with params-itemIDOwner? if not, not allowed to proceed.
	if string(itemOwnerData) != itemIDOwner {

		code := "99"
		msg := "ItemId owner not match. Not allowed to proceed"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil

	}

	//4.2 : Delete the info base on : ownerKey, itemKey
	ctx.GetStub().DelState(string(itemKey))
	ctx.GetStub().DelState(string(itemOwnerKey))

	//5. Update the '*NFT.Minted' -= 1
	mintedAmt := -1 // remove item
	changeTokenMintedAmount(ctx, tokenSymbol, mintedAmt)

	// getTxID
	txID := ctx.GetStub().GetTxID()
	eventPayload := &EventListenerMessage{
		EventName:   "NonFungibleTokenEvent",
		TxId:        txID,
		ItemId:      args[2],
		SymbolId:    "",
		Description: "Burn Item Successfully",
	}
	invokeEventlistener(ctx, eventPayload)

	code := "0"
	msg := "Burn Item Successfully"
	payloads := []string{txID}
	rsData := getResponseData(code, msg, payloads)

	return rsData, nil
}

// transfer
func (s *NFTChainCode) TransferNonFungibleTokenItem(ctx contractapi.TransactionContextInterface, args []string) ([]byte, error) {

	if len(args) != 4 {
		code := "99"
		msg := "Incorrect number of arguments. Expecting 4"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil

	}

	tokenSymbol := args[0]
	itemIDOwnerFrom := args[1] // who is the itemID-owner (From)
	itemIDOwnerTo := args[2]   // who is the itemID-owner (To)
	itemID := []byte(args[3])

	//1. Validation : Is this token-symbol existed ?
	if TokenExists(ctx, tokenSymbol) == false {
		code := "99"
		msg := "Symbol not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil

	}

	//2. Validation : Is this itemID existed ?
	if IsItemIDExisted(ctx, tokenSymbol, itemID) == false {

		code := "99"
		msg := "ItemID not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}

	//4.1 : Get the info of : ownerKey, itemKey
	itemKey := getNonFungibleItemKey(tokenSymbol, itemID)
	itemData, _ := ctx.GetStub().GetState(string(itemKey))
	item := &Item{}
	json.Unmarshal(itemData, &item)

	itemOwnerKey := getNonFungibleOwnerKey(tokenSymbol, itemID)
	itemOwnerData, _ := ctx.GetStub().GetState(string(itemOwnerKey))

	// Validation : Is the item-owner matched with params-itemIDOwner? if not, not allowed to proceed.
	if string(itemOwnerData) != itemIDOwnerFrom {

		code := "99"
		msg := "ItemId owner not match. Not allowed to proceed"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}

	//4.2 : Delete the info base on : ownerKey, itemKey
	ctx.GetStub().DelState(string(itemKey))
	ctx.GetStub().DelState(string(itemOwnerKey))

	//5. Create non-fungibletokenitem & assigned to this new-ItemOwner
	//5.1 Create this new-token-item which is unique
	item = &Item{
		ItemId:       itemID,
		Properties:   item.Properties,
		Metadata:     item.Metadata,
		Endorsements: item.Endorsements,
	}
	itemKey = getNonFungibleItemKey(tokenSymbol, itemID)
	itemData, _ = json.Marshal(item)
	ctx.GetStub().PutState(string(itemKey), itemData)

	//5.2 Assign this new-itemID to this new-ItemOwner
	itemOwnerKey = getNonFungibleOwnerKey(tokenSymbol, itemID)
	ctx.GetStub().PutState(string(itemOwnerKey), []byte(itemIDOwnerTo))

	// getTxID
	txID := ctx.GetStub().GetTxID()
	eventPayload := &EventListenerMessage{
		EventName:   "NonFungibleTokenEvent",
		TxId:        txID,
		ItemId:      args[2],
		SymbolId:    "",
		Description: "Transfer Item Successfully",
	}
	invokeEventlistener(ctx, eventPayload)

	code := "0"
	msg := "Transfer Item Successfully"
	payloads := []string{txID}
	rsData := getResponseData(code, msg, payloads)

	return rsData, nil
}

// endorse
func (s *NFTChainCode) EndorseNonFungibleTokenItem(ctx contractapi.TransactionContextInterface, args []string) ([]byte, error) {
	// Args:
	// 1- Symbol
	// 2- Item-id
	// Endorsement is sender wallet address. Ignore duplicated.

	if len(args) != 2 {

		code := "99"
		msg := "Incorrect number of arguments. Expecting 2"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil

	}

	tokenSymbol := args[0]
	itemID := []byte(args[1])

	//1. Validation : Is this token-symbol existed ?
	if TokenExists(ctx, tokenSymbol) == false {
		code := "99"
		msg := "Symbol not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil

	}

	//2. Validation : Is this itemID existed ?
	if IsItemIDExisted(ctx, tokenSymbol, itemID) == false {
		code := "99"
		msg := "ItemID not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil

	}

	//3. Get the singer of the endorsement
	_, err := ctx.GetClientIdentity().GetMSPID() // get information about tx creator
	if err != nil {
		code := "99"
		msg := err.Error()
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}
	// get the endorser
	endorsementSigner, err := ctx.GetClientIdentity().GetID()
	if err != nil {
		fmt.Printf("\nEndorser : %v", (endorsementSigner))
	}

	//4.1 : Get the info of : itemKey
	itemKey := getNonFungibleItemKey(tokenSymbol, itemID)
	nonFungibleTokenItem := getNonFungibleItem(ctx, tokenSymbol, itemID) // 先讀取
	if nonFungibleTokenItem == nil {
		code := "99"
		msg := "Item not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}

	// update endorser
	nonFungibleTokenItem.Endorsements = []string{endorsementSigner} // 再修改,
	latestTokenItemData, _ := json.Marshal(nonFungibleTokenItem)
	ctx.GetStub().PutState(string(itemKey), latestTokenItemData) // 最後寫入

	// getTxID
	txID := ctx.GetStub().GetTxID()
	eventPayload := &EventListenerMessage{
		EventName:   "NonFungibleTokenEvent",
		TxId:        txID,
		ItemId:      args[1],
		SymbolId:    "",
		Description: "Endorsed Item Successfully",
	}
	invokeEventlistener(ctx, eventPayload)

	code := "0"
	msg := "Endorsed Item Successfully"
	payloads := []string{txID}
	rsData := getResponseData(code, msg, payloads)
	return rsData, nil

}

// getItem
func (s *NFTChainCode) GetItemInfo(ctx contractapi.TransactionContextInterface, args []string) ([]byte, error) {

	if len(args) != 2 {

		code := "99"
		msg := "Incorrect number of arguments. Expecting 2"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}

	tokenSymbol := args[0]
	itemID := []byte(args[1])

	//1. Validation : Is this token-symbol existed ?
	if TokenExists(ctx, tokenSymbol) == false {

		code := "99"
		msg := "Symbol not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil

	}

	//2. Validation : Is this itemID existed ?
	if IsItemIDExisted(ctx, tokenSymbol, itemID) == false {

		code := "99"
		msg := "ItemID not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}

	nonFungibleTokenItem := getNonFungibleItem(ctx, tokenSymbol, itemID)
	if nonFungibleTokenItem == nil {
		code := "99"
		msg := "Item not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}

	itemData, _ := json.Marshal(nonFungibleTokenItem)
	eventPayload := &EventListenerMessage{
		EventName:   "NonFungibleTokenEvent",
		TxId:        "",
		ItemId:      "",
		SymbolId:    "",
		Description: "Get Item Info Successfully",
	}
	invokeEventlistener(ctx, eventPayload)

	return itemData, nil

}

// getToken
func (s *NFTChainCode) GetTokenInfo(ctx contractapi.TransactionContextInterface, args []string) ([]byte, error) {

	if len(args) != 1 {

		code := "99"
		msg := "Incorrect number of arguments. Expecting 1"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil

	}

	tokenSymbol := args[0]

	//1. Validation : Is this token-symbol existed ?
	if TokenExists(ctx, tokenSymbol) == false {

		code := "99"
		msg := "Symbol not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}

	nonFungibleToken := getNonFungibleToken(ctx, tokenSymbol)
	if nonFungibleToken == nil {
		code := "99"
		msg := "Token not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)
		return rsData, nil
	}

	tokenData, _ := json.Marshal(nonFungibleToken)
	eventPayload := &EventListenerMessage{
		EventName:   "NonFungibleTokenEvent",
		TxId:        "",
		ItemId:      "",
		SymbolId:    "",
		Description: "Get Token Info Successfully",
	}
	invokeEventlistener(ctx, eventPayload)

	return tokenData, nil

}

/********************* start : sub() ****************************************/

func IsItemIDExisted(ctx contractapi.TransactionContextInterface, symbol string, itemID []byte) bool {

	item := getNonFungibleItem(ctx, symbol, itemID)
	if item != nil {
		return true
	}

	return false
}

func getNonFungibleToken(ctx contractapi.TransactionContextInterface, symbol string) *NFT {
	tokenKey := symbol

	tokenValue, _ := getKey(ctx, string(tokenKey))
	if tokenValue == nil {
		return nil
	}

	var token = new(NFT)
	json.Unmarshal(tokenValue, token)

	return token
}

func getNonFungibleItem(ctx contractapi.TransactionContextInterface, symbol string, itemID []byte) *Item {
	itemKey := getNonFungibleItemKey(symbol, itemID)

	itemValue, _ := getKey(ctx, string(itemKey))
	if itemValue == nil {
		return nil
	}
	var item = new(Item)
	json.Unmarshal(itemValue, item)

	return item
}

func getNonFungibleItemKey(symbol string, itemID []byte) []byte {
	prefixNonFungibleItem := []byte("0x01") // prefix

	key := make([]byte, 0, len(prefixNonFungibleItem)+1+len(symbol)+1+len(itemID))
	key = append(key, prefixNonFungibleItem...)
	key = append(key, ':')
	key = append(key, []byte(symbol)...)
	key = append(key, ':')
	key = append(key, itemID...)

	return key
}

// QueryAlltoken returns all symbols found in world state
func (s *NFTChainCode) QueryAllnft(ctx contractapi.TransactionContextInterface) ([]QueryResult, error) {
	startKey := "symbol0"
	endKey := "symbol5"

	resultsIterator, err := ctx.GetStub().GetStateByRange(startKey, endKey)

	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []QueryResult{}

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()

		if err != nil {
			return nil, err
		}

		nft := new(NFT)
		_ = json.Unmarshal(queryResponse.Value, nft)

		queryResult := QueryResult{Key: queryResponse.Key, Record: nft}
		results = append(results, queryResult)
	}

	return results, nil
}

// MINT
func getNonFungibleOwnerKey(symbol string, itemID []byte) []byte {
	prefixNonFungibleOwner := []byte("0x02")

	key := make([]byte, 0, len(prefixNonFungibleOwner)+1+len(symbol)+1+len(itemID))
	key = append(key, prefixNonFungibleOwner...)
	key = append(key, ':')
	key = append(key, []byte(symbol)...)
	key = append(key, ':')
	key = append(key, itemID...)

	return key
}

func getResponseData(code string, msg string, payloads []string) []byte {

	rs := &ResponseMessage{
		Code:    code,
		Message: msg,
		Payload: payloads,
	}
	rsData, _ := json.Marshal(rs)

	return rsData
}

// OK:
func TokenExists(ctx contractapi.TransactionContextInterface, symbol string) bool {

	tokenValue, _ := getKey(ctx, symbol)
	if tokenValue != nil {
		return true
	}

	return false
}

// OK:
func getKey(ctx contractapi.TransactionContextInterface, symbol string) ([]byte, error) {
	return ctx.GetStub().GetState(symbol)
}

/********************* start : main() ****************************************/

// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {

	// Create a new Chaincode

	chaincode, err := contractapi.NewChaincode(new(NFTChainCode))

	if err != nil {
		fmt.Printf("Error create fabcar chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting fabcar chaincode: %s", err.Error())
	}
}
