package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"
	"time"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	sc "github.com/hyperledger/fabric-protos-go/peer"
	"github.com/hyperledger/fabric/common/flogging"

	"github.com/hyperledger/fabric-chaincode-go/pkg/cid"
	
)

// SmartContract Define the Smart Contract structure
type SmartContract struct {
}

// Evento: estrutura definida dos eventos baseada no output do docker events.  Structure tags are used by encoding/json library
type Event struct {
	Status   	string `json:"status,omitempty"`
	EventID  	string `json:"EventID,omitempty"`
	From     	string `json:"from,omitempty"`
	Type     	string `json:"Type"`
	Action  	string `json:"Action"`
	ActorID  string `json:"ActorID"` //Criei o actor e seus subcampos como o tipo Actor
	Replicasnew string `json:"replicas.new,omitempty"`
	Replicasold string `json:"replicas.old,omitempty"`
	Image    string `json:"Image,omitempty"`
	Name     string `json:"name"`
	Scope    string `json:"scope"`
	Time     string `json:"time"`
	TimeNano string `json:"timeNano"`
	Sender   string
	TxID	 string
}

// Detalhes
type eventPrivateDetails struct {
	ActorID string `json:"ActorID"`
	Image   string `json:"Image"`
	Name    string `json:"name"`
}

// type Attributes struct {
// 	Image string `json:"Image"`
// 	name  string `json:"name"`
// }

// Init ;  Method for initializing smart contract
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

var logger = flogging.MustGetLogger("event_cc")

// Invoke :  Method for INVOKING smart contract
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	function, args := APIstub.GetFunctionAndParameters()
	logger.Infof("Function name is:  %d", function)
	logger.Infof("Args length is : %d", len(args))

	switch function {
	case "queryEvent":
		return s.queryEvent(APIstub, args)
	case "initLedger":
		return s.initLedger(APIstub)
	case "createEvent":
		return s.createEvent(APIstub, args)
	// case "createServiceEvent":
	// 	return s.createServiceEvent(APIstub, args)
	case "queryAllEvents":
		return s.queryAllEvents(APIstub)
		// Função changeEventOwner permanece por enqto, mas não faz sentido manter.
	case "changeEventOwner":
		return s.changeEventOwner(APIstub, args)
	case "getHistoryForAsset":
		return s.getHistoryForAsset(APIstub, args)
	//case "queryEventsByActor":
	//	return s.queryEventsByActor(APIstub, args)
	case "restictedMethod":
		return s.restictedMethod(APIstub, args)
	case "test":
		return s.test(APIstub, args)
		//  Verificar se faz sentido função createPrivateEvent.
	case "createPrivateEvent":
		return s.createPrivateEvent(APIstub, args)
	case "readPrivateEvent":
		return s.readPrivateEvent(APIstub, args)
	case "updatePrivateData":
		return s.updatePrivateData(APIstub, args)
	//case "readEventActor":
	//	return s.readEventActor(APIstub, args)
	case "createPrivateEventImplicitForProvedor":
		return s.createPrivateEventImplicitForProvedor(APIstub, args)
	case "createPrivateEventImplicitForDesenvolvedor":
		return s.createPrivateEventImplicitForDesenvolvedor(APIstub, args)
	case "createPrivateEventImplicitForUsuario":
		return s.createPrivateEventImplicitForUsuario(APIstub, args)
	case "queryPrivateDataHash":
		return s.queryPrivateDataHash(APIstub, args)
	case "GetCreator":
		return s.GetCreator(APIstub)
	default:
		return shim.Error("Invalid Smart Contract function name.")
	}

	// return shim.Error("Invalid Smart Contract function name.")
}

func (s *SmartContract) GetCreator(APIstub shim.ChaincodeStubInterface) sc.Response {

	// if len(args) != 1 {
	// 	return shim.Error("Incorrect number of arguments. Expecting 1")
	// }

	sender, _ := APIstub.GetCreator()
	return shim.Success(sender)
}

func (s *SmartContract) queryEvent(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	eventAsBytes, _ := APIstub.GetState(args[0])
	return shim.Success(eventAsBytes)
}

func (s *SmartContract) readPrivateEvent(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}
	// collectionCars, collectioneventPrivateDetails, _implicit_org_Org1MSP, _implicit_org_Org2MSP
	eventAsBytes, err := APIstub.GetPrivateData(args[0], args[1])
	if err != nil {
		jsonResp := "{\"Error\":\"Failed to get private details for " + args[1] + ": " + err.Error() + "\"}"
		return shim.Error(jsonResp)
	} else if eventAsBytes == nil {
		jsonResp := "{\"Error\":\"Event private details does not exist: " + args[1] + "\"}"
		return shim.Error(jsonResp)
	}
	return shim.Success(eventAsBytes)
}

func (s *SmartContract) readPrivateEventImpleciteForProvedor(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	eventAsBytes, _ := APIstub.GetPrivateData("_implicit_org_ProvedorMSP", args[0])
	return shim.Success(eventAsBytes)
}

func (s *SmartContract) readeventPrivateDetails(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	eventAsBytes, err := APIstub.GetPrivateData("collectioneventPrivateDetails", args[0])

	if err != nil {
		jsonResp := "{\"Error\":\"Failed to get private details for " + args[0] + ": " + err.Error() + "\"}"
		return shim.Error(jsonResp)
	} else if eventAsBytes == nil {
		jsonResp := "{\"Error\":\"Marble private details does not exist: " + args[0] + "\"}"
		return shim.Error(jsonResp)
	}
	return shim.Success(eventAsBytes)
}

func (s *SmartContract) test(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	eventAsBytes, _ := APIstub.GetState(args[0])
	return shim.Success(eventAsBytes)
}

func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	events := []Event{

		// Event{Status: "Start", EventID: "aba4d6a5b225e82c51e737462f1ab8570b06a84887c3ed2058446ee60692dd97", From: "hyperledger/fabric-couchdb", Type: "container", Action: "Start", ActorID: "aba4d6a5b225e82c51e737462f1ab8570b06a84887c3ed2058446ee60692dd97", Image: "hyperledger/fabric-couchdb", Name: "couchdb4", Scope: "local", Time: "1599452346", TimeNano: "1599452346387699816"},
		// Event{Status: "Stop", EventID: "aba4d6a5b225e82c51e737462f1ab8570b06a84887c3ed2058446ee60692dd97", From: "hyperledger/fabric-couchdb", Type: "container", Action: "Stop", ActorID: "aba4d6a5b225e82c51e737462f1ab8570b06a84887c3ed2058446ee60692dd97", Image: "hyperledger/fabric-couchdb", Name: "couchdb4", Scope: "local", Time: "1599452346", TimeNano: "1599452346387699816"},
	}

	i := 0
	for i < len(events) {
		eventAsBytes, _ := json.Marshal(events[i])
		APIstub.PutState("EVENT"+strconv.Itoa(i), eventAsBytes)
		i = i + 1
	}

	return shim.Success(nil)
}

func (s *SmartContract) createPrivateEvent(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	type EventTransientInput struct {
		Status   string `json:"status"`
		EventID  string `json:"EventID"`
		From     string `json:"from"`
		Type     string `json:"Type"`
		Action   string `json:"Action"`
		ActorID  string `json:"ActorID"`
		replicasnew string `json:"replicasnew"`
		replicasold string `json:"replicasold"`
		Image    string `json:"Image"`
		Name     string `json:"name"`
		Scope    string `json:"scope"`
		Time     string `json:"time"`
		TimeNano string `json:"timeNano"`
		Key      string `json:"key"`
	}

	if len(args) != 0 {
		return shim.Error("1111111----Incorrect number of arguments. Private marble data must be passed in transient map.")
	}

	logger.Infof("11111111111111111111111111")

	transMap, err := APIstub.GetTransient()
	if err != nil {
		return shim.Error("222222 -Error getting transient: " + err.Error())
	}

	EventDataAsBytes, ok := transMap["event"]
	if !ok {
		return shim.Error("Event must be a key in the transient map")
	}
	logger.Infof("********************8   " + string(EventDataAsBytes))

	if len(EventDataAsBytes) == 0 {
		return shim.Error("333333 -marble value in the transient map must be a non-empty JSON string")
	}

	logger.Infof("2222222")

	var eventInput EventTransientInput
	err = json.Unmarshal(EventDataAsBytes, &eventInput)
	if err != nil {
		return shim.Error("44444 -Failed to decode JSON of: " + string(EventDataAsBytes) + "Error is : " + err.Error())
	}

	logger.Infof("3333")

	if len(eventInput.Key) == 0 {
		return shim.Error("name field must be a non-empty string")
	}
	if len(eventInput.Status) == 0 {
		return shim.Error("Status field must be a non-empty string")
	}
	if len(eventInput.EventID) == 0 {
		return shim.Error("EventID field must be a non-empty string")
	}
	if len(eventInput.From) == 0 {
		return shim.Error("From field must be a non-empty string")
	}
	if len(eventInput.Type) == 0 {
		return shim.Error("Type field must be a non-empty string")
	}
	if len(eventInput.Action) == 0 {
		return shim.Error("Action field must be a non-empty string")
	}
	if len(eventInput.ActorID) == 0 {
		return shim.Error("ActorID field must be a non-empty string")
	}
	if len(eventInput.Name) == 0 {
		return shim.Error("name field must be a non-empty string")
	}
	if len(eventInput.Image) == 0 {
		return shim.Error("Image field must be a non-empty string")
	}
	if len(eventInput.Scope) == 0 {
		return shim.Error("Scope field must be a non-empty string")
	}
	if len(eventInput.Time) == 0 {
		return shim.Error("Time field must be a non-empty string")
	}
	if len(eventInput.TimeNano) == 0 {
		return shim.Error("TimeNano field must be a non-empty string")
	}

	logger.Infof("444444")

	// ==== Check if event already exists ====
	eventAsBytes, err := APIstub.GetPrivateData("collectionEvents", eventInput.Key)
	if err != nil {
		return shim.Error("Failed to get marble: " + err.Error())
	} else if eventAsBytes != nil {
		fmt.Println("This event already exists: " + eventInput.Key)
		return shim.Error("This event already exists: " + eventInput.Key)
	}

	logger.Infof("55555")

	var event = Event{}

	eventAsBytes, err = json.Marshal(event)
	if err != nil {
		return shim.Error(err.Error())
	}
	err = APIstub.PutPrivateData("collectionEvents", eventInput.Key, eventAsBytes)
	if err != nil {
		logger.Infof("6666666")
		return shim.Error(err.Error())
	}

	eventPrivateDetails := &eventPrivateDetails{ActorID: eventInput.ActorID, Image: eventInput.Image, Name: eventInput.Name}

	eventPrivateDetailsAsBytes, err := json.Marshal(eventPrivateDetails)
	if err != nil {
		logger.Infof("77777")
		return shim.Error(err.Error())
	}

	err = APIstub.PutPrivateData("collectioneventPrivateDetails", eventInput.Key, eventPrivateDetailsAsBytes)
	if err != nil {
		logger.Infof("888888")
		return shim.Error(err.Error())
	}

	return shim.Success(eventAsBytes)
}

func (s *SmartContract) updatePrivateData(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	type eventTransientInput struct {
		ActorID string `json:"ActorID"`
		Image   string `json:"Image"`
		Name    string `json:"name"`
		replicasnew string `json:"replicasnew"`
		replicasold string `json:"replicasold"`
		Key     string `json:"key"`
	}
	if len(args) != 0 {
		return shim.Error("1111111----Incorrect number of arguments. Private marble data must be passed in transient map.")
	}

	logger.Infof("11111111111111111111111111")

	transMap, err := APIstub.GetTransient()
	if err != nil {
		return shim.Error("222222 -Error getting transient: " + err.Error())
	}

	EventDataAsBytes, ok := transMap["event"]
	if !ok {
		return shim.Error("event must be a key in the transient map")
	}
	logger.Infof("********************8   " + string(EventDataAsBytes))

	if len(EventDataAsBytes) == 0 {
		return shim.Error("333333 -marble value in the transient map must be a non-empty JSON string")
	}

	logger.Infof("2222222")

	var eventInput eventTransientInput
	err = json.Unmarshal(EventDataAsBytes, &eventInput)
	if err != nil {
		return shim.Error("44444 -Failed to decode JSON of: " + string(EventDataAsBytes) + "Error is : " + err.Error())
	}

	eventPrivateDetails := &eventPrivateDetails{ActorID: eventInput.ActorID, Image: eventInput.Image, Name: eventInput.Name}

	eventPrivateDetailsAsBytes, err := json.Marshal(eventPrivateDetails)
	if err != nil {
		logger.Infof("77777")
		return shim.Error(err.Error())
	}

	err = APIstub.PutPrivateData("collectioneventPrivateDetails", eventInput.Key, eventPrivateDetailsAsBytes)
	if err != nil {
		logger.Infof("888888")
		return shim.Error(err.Error())
	}

	return shim.Success(eventPrivateDetailsAsBytes)

}

func (s *SmartContract) createEvent(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	// if len(args) != 12 {
	// 	return shim.Error("Incorrect number of arguments. Expecting 12")
	// }

	/// novooooo

	x509, _ := cid.GetX509Certificate(APIstub)
	sender := x509.Subject.CommonName
	transID := APIstub.GetTxID()
	
	//////////

	if args[1]=="service" {
		var event = Event{
			Type: args[1], 
			Action: args[2], 
			ActorID: args[3], 
			Name: args[4], 
			Replicasnew: args[5], 
			Replicasold: args[6],
			Scope: args[7],
			Time: args[8], 
			TimeNano: args[9], 
			Sender: sender, 
			TxID: transID}

		eventAsBytes, _ := json.Marshal(event)
		APIstub.PutState(args[0], eventAsBytes)

		indexName := "name~ActorID"
		colorNameIndexKey, err := APIstub.CreateCompositeKey(indexName, []string{event.ActorID}) //, args[0]})
		
		if err != nil {
			return shim.Error(err.Error())
		}
		value := []byte{0x00}
		APIstub.PutState(colorNameIndexKey, value)

		return shim.Success(eventAsBytes)

	} else {
		var event = Event{
			Status: args[1], 
			EventID: args[2], 
			From: args[3], 
			Type: args[4], 
			Action: args[5], 
			ActorID: args[6], 
			Image: args[7], 
			Name: args[8], 
			Scope: args[9], 
			Time: args[10], 
			TimeNano: args[11], 
			Sender: sender, 
			TxID: transID}

		eventAsBytes, _ := json.Marshal(event)
		APIstub.PutState(args[0], eventAsBytes)

		indexName := "name~ActorID"
		// colorNameIndexKey, err := APIstub.CreateCompositeKey(indexName, []string{event.Name, event.ActorID}) //, args[0]})
		colorNameIndexKey, err := APIstub.CreateCompositeKey(indexName, []string{event.ActorID}) //, args[0]})
		
		if err != nil {
			return shim.Error(err.Error())
		}
		value := []byte{0x00}
		APIstub.PutState(colorNameIndexKey, value)

		return shim.Success(eventAsBytes)
	}


}

// func (s *SmartContract) createServiceEvent(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

// 	if len(args) != 11 {
// 		return shim.Error("Incorrect number of arguments. Expecting 11")
// 	}

// 	var event = Event{Type: args[1], Action: args[2], ActorID: args[3], Name: args[4], replicasnew: args[5], replicasold: args[6], Time: args[7], TimeNano: args[8]}
	
// 	eventAsBytes, _ := json.Marshal(event)
// 	APIstub.PutState(args[0], eventAsBytes)

// 	indexName := "name~id"
// 	// colorNameIndexKey, err := APIstub.CreateCompositeKey(indexName, []string{event.name, event.ActorID}) //, args[0]})
// 	colorNameIndexKey, err := APIstub.CreateCompositeKey(indexName, []string{event.ActorID}) //, args[0]})
// 	if err != nil {
// 		return shim.Error(err.Error())
// 	}
// 	value := []byte{0x00}
// 	APIstub.PutState(colorNameIndexKey, value)

// 	return shim.Success(eventAsBytes)
// }

func (S *SmartContract) queryEventsByEventID(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments")
	}
	EventID := args[2]
	EventName := args[8]

	ownerAndIDResultIterator, err := APIstub.GetStateByPartialCompositeKey("name~id", []string{EventName, EventID})
	if err != nil {
		return shim.Error(err.Error())
	}

	defer ownerAndIDResultIterator.Close()

	var i int
	var id string

	var events []byte
	bArrayMemberAlreadyWritten := false

	events = append([]byte("["))

	for i = 0; ownerAndIDResultIterator.HasNext(); i++ {
		responseRange, err := ownerAndIDResultIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		objectType, compositeKeyParts, err := APIstub.SplitCompositeKey(responseRange.Key)
		if err != nil {
			return shim.Error(err.Error())
		}

		id = compositeKeyParts[1]
		assetAsBytes, err := APIstub.GetState(id)

		if bArrayMemberAlreadyWritten == true {
			newBytes := append([]byte(","), assetAsBytes...)
			events = append(events, newBytes...)

		} else {
			// newBytes := append([]byte(","), carsAsBytes...)
			events = append(events, assetAsBytes...)
		}

		fmt.Printf("Found a asset for index : %s asset id : ", objectType, compositeKeyParts[0], compositeKeyParts[1])
		bArrayMemberAlreadyWritten = true

	}

	events = append(events, []byte("]")...)

	return shim.Success(events)
}

func (s *SmartContract) queryAllEvents(APIstub shim.ChaincodeStubInterface) sc.Response {

	startKey := ""
	endKey := ""
	// query :=""
	
	// let queryString = {
	// 	"selector": {}
	// }

	// let resultsIterator = await ctx.stub.getQueryResult(JSON.stringify(queryString));

	resultsIterator, err := APIstub.GetStateByRange(startKey, endKey)
	// resultsIterator, err := APIstub.GetQueryResult(queryString)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- queryAllEvents:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

func (s *SmartContract) restictedMethod(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	// get an ID for the client which is guaranteed to be unique within the MSP
	//id, err := cid.GetID(APIstub) -

	// get the MSP ID of the client's identity
	//mspid, err := cid.GetMSPID(APIstub) -

	// get the value of the attribute
	//val, ok, err := cid.GetAttributeValue(APIstub, "attr1") -

	// get the X509 certificate of the client, or nil if the client's identity was not based on an X509 certificate
	//cert, err := cid.GetX509Certificate(APIstub) -

	val, ok, err := cid.GetAttributeValue(APIstub, "role")
	if err != nil {
		// There was an error trying to retrieve the attribute
		shim.Error("Error while retriving attributes")
	}
	if !ok {
		// The client identity does not possess the attribute
		shim.Error("Client identity doesnot posses the attribute")
	}
	// Do something with the value of 'val'
	if val != "approver" {
		fmt.Println("Attribute role: " + val)
		return shim.Error("Only user with role as APPROVER have access this method!")
	} else {
		if len(args) != 1 {
			return shim.Error("Incorrect number of arguments. Expecting 1")
		}

		eventAsBytes, _ := APIstub.GetState(args[0])
		return shim.Success(eventAsBytes)
	}

}

func (s *SmartContract) changeEventOwner(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	eventAsBytes, _ := APIstub.GetState(args[0])
	event := Event{}

	json.Unmarshal(eventAsBytes, &event)
	// event.ActorID = args[1]

	eventAsBytes, _ = json.Marshal(event)
	APIstub.PutState(args[0], eventAsBytes)

	return shim.Success(eventAsBytes)
}

func (t *SmartContract) getHistoryForAsset(stub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	eventName := args[0]

	resultsIterator, err := stub.GetHistoryForKey(eventName)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing historic values for the marble
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		// if it was a delete operation on given key, then we need to set the
		//corresponding value null. Else, we will write the response.Value
		//as-is (as the Value itself a JSON marble)
		if response.IsDelete {
			buffer.WriteString("null")
		} else {
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- getHistoryForAsset returning:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

func (s *SmartContract) createPrivateEventImplicitForProvedor(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	// if len(args) != 12 {
	// 	return shim.Error("Incorrect number of arguments. Expecting 12")
	// }

	// var event = Event{Status: args[1], EventID: args[2], From: args[3], Type: args[4], Action: args[5], ActorID: args[6], Image: args[8], Name: args[9], Scope: args[10], Time: args[11], TimeNano: args[12]}
	var event = Event{}
	eventAsBytes, _ := json.Marshal(event)
	// APIstub.PutState(args[0], eventAsBytes)

	err := APIstub.PutPrivateData("_implicit_org_ProvedorMSP", args[0], eventAsBytes)
	if err != nil {
		return shim.Error("Failed to add asset: " + args[0])
	}
	return shim.Success(eventAsBytes)
}

func (s *SmartContract) createPrivateEventImplicitForDesenvolvedor(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	// if len(args) != 12 {
	// 	return shim.Error("Incorrect number of arguments. Expecting 12")
	// }

	// var event = Event{Status: args[1], EventID: args[2], From: args[3], Type: args[4], Action: args[5], ActorID: args[6], Image: args[8], Name: args[9], Scope: args[10], Time: args[11], TimeNano: args[12]}
	var event = Event{}
	eventAsBytes, _ := json.Marshal(event)
	APIstub.PutState(args[0], eventAsBytes)

	err := APIstub.PutPrivateData("_implicit_org_DesenvolvedorMSP", args[0], eventAsBytes)
	if err != nil {
		return shim.Error("Failed to add asset: " + args[0])
	}
	return shim.Success(eventAsBytes)
}

func (s *SmartContract) createPrivateEventImplicitForUsuario(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	// if len(args) != 12 {
	// 	return shim.Error("Incorrect number of arguments. Expecting 12")
	// }

	// var event = Event{Status: args[1], EventID: args[2], From: args[3], Type: args[4], Action: args[5], ActorID: args[6], Image: args[8], Name: args[9], Scope: args[10], Time: args[11], TimeNano: args[12]}
	//var car = Car{Make: args[1], Model: args[2], Colour: args[3], Owner: args[4]}
	var event = Event{}

	eventAsBytes, _ := json.Marshal(event)
	APIstub.PutState(args[0], eventAsBytes)

	err := APIstub.PutPrivateData("_implicit_org_UsuarioMSP", args[0], eventAsBytes)
	if err != nil {
		return shim.Error("Failed to add asset: " + args[0])
	}
	return shim.Success(eventAsBytes)
}

func (s *SmartContract) queryPrivateDataHash(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}
	eventAsBytes, _ := APIstub.GetPrivateDataHash(args[0], args[1])
	return shim.Success(eventAsBytes)
}


// func (s *smartContract) GetSender(APIstub shim.ChaincodeStubInterface) peer.Response {
//     fmt.Println("GetSender")

//     // GetCreator returns marshaled serialized identity of the client
//     serializedID, _ := stub.GetCreator()

//     sId := &msp.SerializedIdentity{}
//     err := proto.Unmarshal(serializedID, sId)
//     if err != nil {
//         return shim.Error(fmt.Sprintf("Could not deserialize a SerializedIdentity, err %s", err))
//     }

//     bl, _ := pem.Decode(sId.IdBytes)
//     if bl == nil {
//         return shim.Error(fmt.Sprintf("Failed to decode PEM structure"))
//     }
//     cert, err := x509.ParseCertificate(bl.Bytes)
//     if err != nil {
//         return shim.Error(fmt.Sprintf("Unable to parse certificate %s", err))
//     }

//     fmt.Println(serializedID.Subject.CommonName)

//     return shim.Success(nil)
// }

// func (s *SmartContract) CreateCarAsset(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
// 	if len(args) != 1 {
// 		return shim.Error("Incorrect number of arguments. Expecting 1")
// 	}

// 	var car Car
// 	err := json.Unmarshal([]byte(args[0]), &car)
// 	if err != nil {
// 		return shim.Error(err.Error())
// 	}

// 	eventAsBytes, err := json.Marshal(car)
// 	if err != nil {
// 		return shim.Error(err.Error())
// 	}

// 	err = APIstub.PutState(car.ID, eventAsBytes)
// 	if err != nil {
// 		return shim.Error(err.Error())
// 	}

// 	return shim.Success(nil)
// }

// func (s *SmartContract) addBulkAsset(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
// 	logger.Infof("Function addBulkAsset called and length of arguments is:  %d", len(args))
// 	if len(args) >= 500 {
// 		logger.Errorf("Incorrect number of arguments in function CreateAsset, expecting less than 500, but got: %b", len(args))
// 		return shim.Error("Incorrect number of arguments, expecting 2")
// 	}

// 	var eventKeyValue []string

// 	for i, s := range args {

// 		key :=s[0];
// 		var car = Car{Make: s[1], Model: s[2], Colour: s[3], Owner: s[4]}

// 		eventKeyValue = strings.SplitN(s, "#", 3)
// 		if len(eventKeyValue) != 3 {
// 			logger.Errorf("Error occured, Please make sure that you have provided the array of strings and each string should be  in \"EventType#Key#Value\" format")
// 			return shim.Error("Error occured, Please make sure that you have provided the array of strings and each string should be  in \"EventType#Key#Value\" format")
// 		}

// 		assetAsBytes := []byte(eventKeyValue[2])
// 		err := APIstub.PutState(eventKeyValue[1], assetAsBytes)
// 		if err != nil {
// 			logger.Errorf("Error coocured while putting state for asset %s in APIStub, error: %s", eventKeyValue[1], err.Error())
// 			return shim.Error(err.Error())
// 		}
// 		// logger.infof("Adding value for ")
// 		fmt.Println(i, s)

// 		indexName := "Event~Id"
// 		eventAndIDIndexKey, err2 := APIstub.CreateCompositeKey(indexName, []string{eventKeyValue[0], eventKeyValue[1]})

// 		if err2 != nil {
// 			logger.Errorf("Error coocured while putting state in APIStub, error: %s", err.Error())
// 			return shim.Error(err2.Error())
// 		}

// 		value := []byte{0x00}
// 		err = APIstub.PutState(eventAndIDIndexKey, value)
// 		if err != nil {
// 			logger.Errorf("Error coocured while putting state in APIStub, error: %s", err.Error())
// 			return shim.Error(err.Error())
// 		}
// 		// logger.Infof("Created Composite key : %s", eventAndIDIndexKey)

// 	}

// 	return shim.Success(nil)
// }

// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}