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
	ItemId       string
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
	Code        string
	EventName   string
	TxId        string
	ItemId      string
	SymbolId    string
	Description string
}

//================================================= start : testing purpose

func (s *NFTChainCode) InitLedger(ctx contractapi.TransactionContextInterface) error {
	fmt.Printf("\n============= START : Chaincode NFTs is instantiated by the blockchain network :===========")

	return nil

}

//================================================= start : methods

// CreateNonFungibleToken
func (s *NFTChainCode) Create(ctx contractapi.TransactionContextInterface, name string, symbols string, metadata string, totalSupplys string) (*ResponseMessage, error) {

	// verifies that the invoker is under adminRole
	err := ctx.GetClientIdentity().AssertAttributeValue("roletype", "admin")
	if err != nil {
		code := "99"
		msg := "Incorrect roletype attribute : " + err.Error()
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("CreateEvent", rsData)
		return rs, nil
	}

	tokenName := name
	tokenSymbol := symbols
	tokenMetadata := metadata
	tokenSupply, err := strconv.Atoi(totalSupplys)
	if err != nil {

		code := "99"
		msg := "Invalid Total Supply: " + err.Error()
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("CreateEvent", rsData)
		return rs, nil
	}

	invoker, err := ctx.GetClientIdentity().GetID() // get information about tx invoker
	if err != nil {
		code := "99"
		msg := "Error while getting the invoker: " + err.Error()
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("CreateEvent", rsData)
		return rs, nil
	}

	//1.
	fmt.Printf("\nInvoker of Create NFTs: %v", (invoker))

	//2.
	invokerMSP, err := ctx.GetClientIdentity().GetMSPID()
	fmt.Printf("\ninvokerMSP of Create NFTs: %v", (invokerMSP))

	//3.
	invokerX509Certificate, err := ctx.GetClientIdentity().GetX509Certificate()
	fmt.Printf("\ninvoker-X509Certificate of Create NFTs: %v", string(invokerX509Certificate.Raw))

	//2. Validation : Is this token-symbol existed ?
	if TokenExists(ctx, tokenSymbol) {
		code := "99"
		msg := "Symbol already existed."
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("CreateEvent", rsData)
		return rs, nil
	}

	//3. Construct the Token Object, then save into blockchain
	token := &NFT{
		Name:        tokenName,
		Symbol:      tokenSymbol,
		Creator:     invoker,
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

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("CreateEvent", rsData)
		return rs, nil
	}

	// getTxID
	txID := ctx.GetStub().GetTxID()

	eventPayload := &EventListenerMessage{
		Code:        "0",
		EventName:   "CreateEvent",
		TxId:        txID,
		ItemId:      "",
		SymbolId:    tokenSymbol,
		Description: "Create Token Successfully",
	}
	invokeEventlistener(ctx, eventPayload)

	code := "0"
	msg := "Create Token Successfully"
	payloads := []string{txID, invoker}
	rsData := getResponseData(code, msg, payloads)
	rs := new(ResponseMessage)
	_ = json.Unmarshal(rsData, rs)

	return rs, nil

}

// mintNonFungibleTokenItem
func (s *NFTChainCode) Mint(ctx contractapi.TransactionContextInterface, symbols string, owner string, itemId string, properties string, metadata string) (*ResponseMessage, error) {

	// verifies that the invoker is under adminRole
	err := ctx.GetClientIdentity().AssertAttributeValue("roletype", "admin")
	if err != nil {
		code := "99"
		msg := "Incorrect roletype attribute : " + err.Error()
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("MintEvent", rsData)
		return rs, nil
	}

	tokenSymbol := symbols
	itemIDOwner := owner // who is the itemID-owner
	itemID := itemId
	itemProperties := properties
	itemMetadata := metadata

	//2. Validation : Is this token-symbol existed ?
	if TokenExists(ctx, tokenSymbol) == false {
		code := "99"
		msg := "Symbol not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("MintEvent", rsData)
		return rs, nil
	}

	//3.1 Validation : Is this itemID existed ?
	if IsItemIDExisted(ctx, tokenSymbol, itemID) == true {
		code := "99"
		msg := "ItemID already exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("MintEvent", rsData)
		return rs, nil
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

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("MintEvent", rsData)
		return rs, nil

	}

	// invokerX509Certificate, err := ctx.GetClientIdentity().GetX509Certificate()
	// fmt.Printf("\ninvoker-X509Certificate of Mint Item: %v", string(invokerX509Certificate.Raw))

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

	txID := ctx.GetStub().GetTxID()
	eventPayload := &EventListenerMessage{
		Code:        "0",
		EventName:   "MintEvent",
		TxId:        txID,
		ItemId:      itemId,
		SymbolId:    "",
		Description: "Mint Item Successfully",
	}
	invokeEventlistener(ctx, eventPayload)

	code := "0"
	msg := "Mint Item Successfully"
	payloads := []string{txID}
	rsData := getResponseData(code, msg, payloads)
	rs := new(ResponseMessage)
	_ = json.Unmarshal(rsData, rs)
	return rs, nil

}

// sub :  Update the '*NFT.Minted' += 1
func changeTokenMintedAmount(ctx contractapi.TransactionContextInterface, symbol string, minted int) {

	initTokenValue, _ := ctx.GetStub().GetState(symbol) // get
	nonFungibleToken := NFT{}
	json.Unmarshal(initTokenValue, &nonFungibleToken)

	// add new record - base on new-owner
	nonFungibleToken.Minted = nonFungibleToken.Minted + minted // Update the 'minted' amount
	latestTokenValue, _ := json.Marshal(nonFungibleToken)
	ctx.GetStub().PutState(symbol, latestTokenValue) // commit

	return
}

// burnNonFungibleTokenItem
func (s *NFTChainCode) Burn(ctx contractapi.TransactionContextInterface, symbols string, owner string, itemId string) (*ResponseMessage, error) {

	tokenSymbol := symbols
	itemIDOwner := owner // who is the itemID-owner
	itemID := (itemId)

	//1. Validation : Is this token-symbol existed ?
	if TokenExists(ctx, tokenSymbol) == false {

		code := "99"
		msg := "Symbol not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("BurnEvent", rsData)
		return rs, nil

	}

	//2. Validation : Is this itemID existed ?
	if IsItemIDExisted(ctx, tokenSymbol, itemID) == false {

		code := "99"
		msg := "ItemID not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("BurnEvent", rsData)
		return rs, nil

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

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("BurnEvent", rsData)
		return rs, nil

	}

	invokerX509Certificate, _ := ctx.GetClientIdentity().GetX509Certificate()
	fmt.Printf("\ninvoker-X509Certificate of Burn Item: %v", string(invokerX509Certificate.Raw))

	//4.2 : Delete the info base on : ownerKey, itemKey
	ctx.GetStub().DelState(string(itemKey))
	ctx.GetStub().DelState(string(itemOwnerKey))

	//5. Update the '*NFT.Minted' -= 1
	mintedAmt := -1 // remove item
	changeTokenMintedAmount(ctx, tokenSymbol, mintedAmt)

	txID := ctx.GetStub().GetTxID()
	eventPayload := &EventListenerMessage{
		Code:        "0",
		EventName:   "BurnEvent",
		TxId:        txID,
		ItemId:      itemId,
		SymbolId:    symbols,
		Description: "Burn Item Successfully",
	}
	invokeEventlistener(ctx, eventPayload)

	code := "0"
	msg := "Burn Item Successfully"
	payloads := []string{txID}
	rsData := getResponseData(code, msg, payloads)
	rs := new(ResponseMessage)
	_ = json.Unmarshal(rsData, rs)
	return rs, nil

}

// transferNonFungibleTokenItem
func (s *NFTChainCode) Transfer(ctx contractapi.TransactionContextInterface, symbols string, ownerFrom string, ownerTo string, itemId string) (*ResponseMessage, error) {

	tokenSymbol := symbols
	itemIDOwnerFrom := ownerFrom // who is the itemID-owner (From)
	itemIDOwnerTo := ownerTo     // who is the itemID-owner (To)
	itemID := (itemId)

	//1. Validation : Is this token-symbol existed ?
	if TokenExists(ctx, tokenSymbol) == false {
		code := "99"
		msg := "Symbol not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("TransferEvent", rsData)
		return rs, nil

	}

	//2. Validation : Is this itemID existed ?
	if IsItemIDExisted(ctx, tokenSymbol, itemID) == false {

		code := "99"
		msg := "ItemID not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("TransferEvent", rsData)
		return rs, nil

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

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("TransferEvent", rsData)
		return rs, nil

	}

	invokerX509Certificate, _ := ctx.GetClientIdentity().GetX509Certificate()
	fmt.Printf("\ninvoker-X509Certificate of Transfer Item: %v", string(invokerX509Certificate.Raw))

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

	txID := ctx.GetStub().GetTxID()
	eventPayload := &EventListenerMessage{
		Code:        "0",
		EventName:   "TransferEvent",
		TxId:        txID,
		ItemId:      itemId,
		SymbolId:    "",
		Description: "Transfer Item Successfully",
	}
	invokeEventlistener(ctx, eventPayload)

	code := "0"
	msg := "Transfer Item Successfully"
	payloads := []string{txID}
	rsData := getResponseData(code, msg, payloads)
	rs := new(ResponseMessage)
	_ = json.Unmarshal(rsData, rs)
	return rs, nil

}

// endorseNonFungibleTokenItem
func (s *NFTChainCode) Endorse(ctx contractapi.TransactionContextInterface, symbols string, itemId string) (*ResponseMessage, error) {

	tokenSymbol := symbols
	itemID := (itemId)

	//1. Validation : Is this token-symbol existed ?
	if TokenExists(ctx, tokenSymbol) == false {
		code := "99"
		msg := "Symbol not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("EndorseEvent", rsData)
		return rs, nil

	}

	//2. Validation : Is this itemID existed ?
	if IsItemIDExisted(ctx, tokenSymbol, itemID) == false {
		code := "99"
		msg := "ItemID not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("EndorseEvent", rsData)
		return rs, nil

	}

	//3. Get the singer of the endorsement
	endorser, err := ctx.GetClientIdentity().GetID() // get information about tx invoker
	if err != nil {
		code := "99"
		msg := "Error while getting the endorser: " + err.Error()
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("EndorseEvent", rsData)
		return rs, nil

	}
	fmt.Printf("\nInvoker of Endorsement : %v", (endorser))

	//2.
	endorserMSP, err := ctx.GetClientIdentity().GetMSPID()
	fmt.Printf("\nInvokerMSP of Endorsement: %v", (endorserMSP))

	//3.
	endorserX509Certificate, err := ctx.GetClientIdentity().GetX509Certificate()
	fmt.Printf("\nInvoker-X509Certificate of Endorsement: %v", string(endorserX509Certificate.Raw))

	//4.1 : Get the info of : itemKey
	itemKey := getNonFungibleItemKey(tokenSymbol, itemID)
	nonFungibleTokenItem := getNonFungibleItem(ctx, tokenSymbol, itemID) // get
	if nonFungibleTokenItem == nil {
		code := "99"
		msg := "Item not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("EndorseEvent", rsData)
		return rs, nil

	}

	// update endorser
	nonFungibleTokenItem.Endorsements = []string{endorser} // edit
	latestTokenItemData, _ := json.Marshal(nonFungibleTokenItem)
	ctx.GetStub().PutState(string(itemKey), latestTokenItemData) // commit

	txID := ctx.GetStub().GetTxID()
	eventPayload := &EventListenerMessage{
		Code:        "0",
		EventName:   "EndorseEvent",
		TxId:        txID,
		ItemId:      itemId,
		SymbolId:    symbols,
		Description: "Endorsed Item Successfully",
	}
	invokeEventlistener(ctx, eventPayload)

	code := "0"
	msg := "Endorsed Item Successfully"
	payloads := []string{txID, endorser}
	rsData := getResponseData(code, msg, payloads)
	rs := new(ResponseMessage)
	_ = json.Unmarshal(rsData, rs)
	return rs, nil

}

// getTokenInfo
func (s *NFTChainCode) GetToken(ctx contractapi.TransactionContextInterface, symbols string) (*ResponseMessage, error) {

	tokenSymbol := symbols

	//1. Validation : Is this token-symbol existed ?
	if TokenExists(ctx, tokenSymbol) == false {

		code := "99"
		msg := "Symbol not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("GetTokenEvent", rsData)
		return rs, nil
	}

	nonFungibleToken := getNonFungibleToken(ctx, tokenSymbol)
	if nonFungibleToken == nil {
		code := "99"
		msg := "Token not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("GetTokenEvent", rsData)
		return rs, nil
	}

	tokenData, _ := json.Marshal(nonFungibleToken)

	eventPayload := &EventListenerMessage{
		EventName:   "GetTokenEvent",
		TxId:        "",
		ItemId:      "",
		SymbolId:    "",
		Description: "Get Token Data Successfully",
	}
	invokeEventlistener(ctx, eventPayload)

	py := string(tokenData)
	code := "0"
	msg := ""
	payloads := []string{py}
	rsData := getResponseData(code, msg, payloads)

	rs := new(ResponseMessage)
	_ = json.Unmarshal(rsData, rs)

	// ctx.GetStub().SetEvent("GetTokenEvent", rsData)
	return rs, nil

}

// getItemInfo
func (s *NFTChainCode) GetItem(ctx contractapi.TransactionContextInterface, symbols string, itemId string) (*ResponseMessage, error) {

	tokenSymbol := symbols
	itemID := (itemId)

	//1. Validation : Is this token-symbol existed ?
	if TokenExists(ctx, tokenSymbol) == false {

		code := "99"
		msg := "Symbol not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("GetItemEvent", rsData)
		return rs, nil

	}

	//2. Validation : Is this itemID existed ?
	if IsItemIDExisted(ctx, tokenSymbol, itemID) == false {

		code := "99"
		msg := "ItemID not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("GetItemEvent", rsData)
		return rs, nil

	}

	nonFungibleTokenItem := getNonFungibleItem(ctx, tokenSymbol, itemID)
	if nonFungibleTokenItem == nil {
		code := "99"
		msg := "Item not exist"
		payloads := []string{}
		rsData := getResponseData(code, msg, payloads)

		rs := new(ResponseMessage)
		_ = json.Unmarshal(rsData, rs)

		ctx.GetStub().SetEvent("GetItemEvent", rsData)
		return rs, nil

	}

	itemData, _ := json.Marshal(nonFungibleTokenItem)

	eventPayload := &EventListenerMessage{
		Code:        "0",
		EventName:   "GetItemEvent",
		TxId:        "",
		ItemId:      "",
		SymbolId:    "",
		Description: "Get Item Data Successfully",
	}
	invokeEventlistener(ctx, eventPayload)

	py := string(itemData)
	code := "0"
	msg := ""
	payloads := []string{py}
	rsData := getResponseData(code, msg, payloads)
	rs := new(ResponseMessage)
	_ = json.Unmarshal(rsData, rs)
	return rs, nil

}

func IsItemIDExisted(ctx contractapi.TransactionContextInterface, symbol string, itemID string) bool {

	item := getNonFungibleItem(ctx, symbol, itemID)
	if item != nil {
		return true
	}

	return false
}

// -- Chaincode Event Listener
func invokeEventlistener(ctx contractapi.TransactionContextInterface, event *EventListenerMessage) {

	PayloadData, _ := json.Marshal(event)

	if event.EventName == "" {
		msg := "event name can not be empty string"
		fmt.Printf("\n %v", msg)
		return
	}

	err := ctx.GetStub().SetEvent(event.EventName, PayloadData)
	if err != nil {
		msg := "Failed event listener : " + err.Error()
		fmt.Printf("\n %v", msg)
		return
	}

	return
}

func getNonFungibleToken(ctx contractapi.TransactionContextInterface, symbol string) *NFT {
	tokenKey := symbol

	tokenValue, err := ctx.GetStub().GetState(tokenKey)

	if err != nil {
		return nil
	}

	if tokenValue == nil {
		return nil
	}

	var token = new(NFT)
	json.Unmarshal(tokenValue, token)

	return token
}

func getNonFungibleItem(ctx contractapi.TransactionContextInterface, symbol string, itemID string) *Item {
	itemKey := getNonFungibleItemKey(symbol, itemID)

	itemValue, _ := getKey(ctx, string(itemKey))
	if itemValue == nil {
		return nil
	}

	var item = new(Item)
	json.Unmarshal(itemValue, item)

	return item
}

func getNonFungibleItemKey(symbol string, itemID string) []byte {
	prefixNonFungibleItem := []byte("0x01") // prefix

	key := make([]byte, 0, len(prefixNonFungibleItem)+1+len(symbol)+1+len(itemID))
	key = append(key, prefixNonFungibleItem...)
	key = append(key, ':')
	key = append(key, []byte(symbol)...)
	key = append(key, ':')
	key = append(key, []byte(itemID)...)

	return key
}

func getNonFungibleOwnerKey(symbol string, itemID string) []byte {
	prefixNonFungibleOwner := []byte("0x02") // prefix

	key := make([]byte, 0, len(prefixNonFungibleOwner)+1+len(symbol)+1+len(itemID))
	key = append(key, prefixNonFungibleOwner...)
	key = append(key, ':')
	key = append(key, []byte(symbol)...)
	key = append(key, ':')
	key = append(key, []byte(itemID)...)

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

func TokenExists(ctx contractapi.TransactionContextInterface, symbol string) bool {

	tokenValue, _ := getKey(ctx, symbol)
	if tokenValue == nil {
		return false
	}

	return true
}

func getKey(ctx contractapi.TransactionContextInterface, val string) ([]byte, error) {
	return ctx.GetStub().GetState(val)
}

// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {

	// Create a new Chaincode
	chaincode, err := contractapi.NewChaincode(new(NFTChainCode))

	if err != nil {
		fmt.Printf("Error create NFTs chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting NFTs chaincode: %s", err.Error())
	}
}
