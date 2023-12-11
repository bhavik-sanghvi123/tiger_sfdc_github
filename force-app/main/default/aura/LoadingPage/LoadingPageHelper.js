/*
Copyright 2016 salesforce.com, inc. All rights reserved.

Use of this software is subject to the salesforce.com Developerforce Terms of Use and other applicable terms that salesforce.com may make available, as may be amended from time to time. You may not decompile, reverse engineer, disassemble, attempt to derive the source code of, decrypt, modify, or create derivative works of this software, updates thereto, or any part thereof. You may not use the software to engage in any development activity that infringes the rights of a third party, including that which interferes with, damages, or accesses in an unauthorized manner the servers, networks, or other properties or services of salesforce.com or any third party.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL SALESFORCE.COM HAVE ANY LIABILITY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES, OR DAMAGES BASED ON LOST PROFITS, DATA OR USE, IN CONNECTION WITH THE SOFTWARE, HOWEVER CAUSED AND, WHETHER IN CONTRACT, TORT OR UNDER ANY OTHER THEORY OF LIABILITY, WHETHER OR NOT YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*/

({
    // adds an onCLickToDial listener
    // This listener brings up the softphone every time click to dial is fired
    // and renders the callInitiatedPanel panel with the event payload
    handleOutgoingCalls : function(cmp) {
        var listener = function(payload) {
            sforce.opencti.setSoftphonePanelVisibility({
                visible : true,
                callback : function() {
                    if (cmp.isValid() && cmp.get('v.presence') != 'Unavailable') {
                        var attributes = {
                            'state' : 'Dialing',
                            'recordName' : payload.recordName,
                            'phone' : payload.number,
                            'title' : '',
                            'account' : '',
                            'presence' : cmp.get('v.presence'),
                            'userCred' :cmp.get('v.userCred'),
                            'ifcardselected' :'true'
                        };
                        cmp.getEvent('renderPanel').setParams({
                            type : 'c:callInitiatedPanel',
                            attributes : attributes
                        }).fire();
                    }
                }
            });
        };
        sforce.opencti.onClickToDial({
            listener : listener
        });
    },
    
    

    // toggles the Call button from disabled to enabled, if the input number is valid
    updateButtonStatus : function(cmp) {
        if (this.isValidPhoneNumber(cmp)) {
             cmp.set('v.callDisabled',false);
        } else {
             cmp.set('v.callDisabled',true);
             
        }
    },

    // returns true if phone number is a valid integer, i.e. at least 3 digits
    isValidPhoneNumber : function(cmp) {
        var inputValue = cmp.get('v.inputValue');
        return (inputValue.length >= 3 && !isNaN(parseFloat(inputValue)) && isFinite(inputValue));
    },

    // find a matching record for a number
    // if there's a match - initiate call panel with record details
    // if not, initiate call panel with only number and state
    callNumber : function(cmp, number) {
        var attributes = {
            'state' : 'Dialing',
            'recordName' : number
        };
        var record = cmp.get('v.searchResults')
                && cmp.get('v.searchResults')[0];

        if (record && this.matchingNumbers(number, record.Phone)) {
            attributes.recordName = record.Name;
            attributes.phone = record.Phone;
            attributes.title = record.Title;
            attributes.account = record.Account;
            attributes.recordId = record.Id;
            
        };
                    attributes.userCred = cmp.get('v.userCred');
					 attributes.phone = cmp.get('v.inputValue');
                            attributes.careline = 'true';

        console.log("CALL NUMBER ATTRIBUTE USER CRED : ");
        console.log(attributes.userCred)
        cmp.set('v.searchResults', []);
        this.initiateCallPanel(cmp, attributes);
    },

    // strip alphabetic characters from numbers and returns true if numbers are matching
    matchingNumbers : function(number1, number2){
        var target = number2.replace(/\D/g,'')
        return number1.replace(/\D/g,'') == target && target.length > 0;
    },

    // when clicking on a contact card, initiate call panel with contact card details
    callContact : function(cmp, record) {
        if (!record ) {
            throw new Error('Something went wrong. Try again or contact your admin.');
        };
        var attributes = {
            'state' : 'Dialing',
            'recordName' : record.Name,
            'phone' : record.Phone,
            'title' : record.Title,
            'account' : record.Account,
            'recordId' : record.Id,
             'userCred' :cmp.get('v.userCred')
        };
        console.log('callContact attribute log : ');
        console.log(attributes);
        this.initiateCallPanel(cmp, attributes);
    },

    // find a matching record using Open CTI runApex()
    // optionally run a callback function onCompletion
    search : function(cmp, inputValue, onCompletion) {
        cmp.set('v.searchResults', []);
        if (inputValue.length < 2) {
            cmp.set('v.message', 'Enter at least two characters');
            return;
        };

        var args = {
            apexClass : 'SoftphoneContactSearchController',
            methodName : 'getContacts',
            methodParams : 'name=' + inputValue,
            callback : function(result) {
                if (result.success) {
                    var searchResults = JSON.parse(result.returnValue.runApex);
                    console.log(searchResults);
                    cmp.set('v.searchResults', searchResults);
                    if (searchResults.length == 0) {
                        cmp.set('v.message', 'No results found');
                    }
                    onCompletion && onCompletion(cmp, inputValue);
                } else {
                    throw new Error('Unable to perform a search using Open CTI. Contact your admin.');
                }
            }
        };
        sforce.opencti.runApex(args);
    },
            changeStatusVicidial: function (cmp, event, helper,result) {
            console.log("result :");   
			console.log(result);
            
            
            if (result=="Available"){
                const xhr = new XMLHttpRequest();
                                let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/3/'+cmp.get('v.userCred');

                    xhr.open('GET', url, true);
                    
                    
                    
                    xhr.onload = () => {
                      if (xhr.readyState === xhr.DONE) {
                        if (xhr.status === 200) {
                    
                          console.log(xhr.response);
                          console.log(xhr.responseText);
                        }
                      }
                    };
                    
                    xhr.send(null);
                    
                                }
            if(result == "Paused") {
                        const xhr = new XMLHttpRequest();
                    let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/2/'+cmp.get('v.userCred');

                    xhr.open('GET', url, true);
                    
                    
                    
                    xhr.onload = () => {
                      if (xhr.readyState === xhr.DONE) {
                        if (xhr.status === 200) {
                    
                          console.log(xhr.response);
                          console.log(xhr.responseText);
                        }
                      }
                    };
                    
                    xhr.send(null);
                    
                   					 }
                                     if(result =="Log Out"){
                                                 
        	const Http = new XMLHttpRequest();
        	let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/95/'+cmp.get('v.userCred');
        console.log(url);
            Http.open("GET", url);
            Http.send();
        
        var callback = function(result) {
            if (result.success) {
                cmp.getEvent('renderPanel').setParams({
                    type: 'c:ctiLoginPanel'
                }).fire();
            } else {
                throw new Error('Click to dial cannot be disabled.');
            }
        };
        sforce.opencti.disableClickToDial({
            callback: callback
        });
                                     }
                                     
          },
     getTimeSheet : function(cmp, event, helper,result,onCompletion) {
        if (result == "Available"){
            try{

        const xhr = new XMLHttpRequest();
                
                let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/1/'+cmp.get('v.userCred');
        xhr.open('GET',url , true);
        
        
        
        xhr.onload = () => {
          if (xhr.readyState === xhr.DONE) {
            if (xhr.status === 200) {
        
              console.log(xhr.response);
              console.log(xhr.responseText);
            if(xhr.responseText.includes("INCALL")){
            clearTimeout(this.waitingTime);
        
            //FUNCTION FOR POPUP?
            const myArray = xhr.responseText.split(",");
            console.log(myArray[17]);
            var inputValue = myArray[17];
            console.log(inputValue);
            const inputArray = inputValue.split("");
            if(inputArray[0]=="6"){    
            const citrus = inputArray.slice(1);
             inputValue = citrus.join("");}
             cmp.set('v.searchResults', []);
            var args = {
                    apexClass : 'SoftphoneContactSearchController',
                    methodName : 'getContacts',
                    methodParams : 'name=' + inputValue,
                    callback : function(result) {
                        if (result.success) {
                            var searchResults = JSON.parse(result.returnValue.runApex);
                            console.log("searchResults :");
                            console.log(searchResults);
                            cmp.set('v.searchResults', searchResults);
                            if (searchResults.length == 0) {
                                cmp.set('v.message', 'No results found');
            console.log("NO RECORD DETECTED");
                            }

                            onCompletion && onCompletion(cmp, inputValue);
                                //callPhone START HERE
                                    var attributes = {
                                    'state' : 'Inbound',
                                    'recordName' : inputValue
                                };
                        if(searchResults.length != 0){
                                            var record = cmp.get('v.searchResults')
                                && cmp.get('v.searchResults')[0];
                                       var target = record.Phone.replace(/\D/g,'');
                                     var resultss=  myArray[17].replace(/\D/g,'') == target && target.length > 0;
                                if (record && resultss) {
                                    attributes.recordName = record.Name;
                                    attributes.phone = record.Phone;
                                    attributes.title = record.Title;
                                    attributes.account = record.Account;
                                    attributes.recordId = record.Id;
                                    
                                };
        }
                				 console.log("GET TIME SHEET SUSPECT HERE ");
                				console.log("LETS SEE WHAT IS THE MyArray 17 ");
                 					console.log(myArray[17]);
                                

                               attributes.phone = myArray[17];

                		attributes.userCred = cmp.get('v.userCred');

                            attributes.careline = 'true';

                                attributes.presence = cmp.get('v.presence');
                cmp.getEvent('renderPanel').setParams({
                    type : 'c:callInitiatedPanel',
                    attributes : attributes
                }).fire();
        
                        } else {
                            throw new Error('Unable to perform a search using Open CTI. Contact your admin.');
                        }
                    }
                };
                sforce.opencti.runApex(args);
        //END OF SEARCH
        
            
        }
            }
          }
        };
        
        xhr.send(null);
        
        
        
        this.waitingTime =setTimeout($A.getCallback(() => this.getTimeSheet(cmp, event, helper,result, onCompletion)), 5000);
        }
        catch (ex) {
        console.log('Exception: '+ex);
        }
                    
                }
                else{
                   clearTimeout(this.waitingTime);
                }
},

    // sets the presence to the new presence
    // and updates the message on the phone panel based on the new presense
    updatePresence : function(cmp, event, helper) {
        var newStatus = event.getParams().newStatus;
        cmp.set('v.presence', newStatus);
        var newMessage = 'Search for a contact';
        if (newStatus === 'Available') {
            cmp.set('v.pausecode',"nocode");
        }
        if (newStatus === 'Unavailable') {
            newMessage = "You're currently unavailable for calls";
            cmp.set('v.showDialPad',false);
        }
        cmp.set('v.message', newMessage);
    },

    // renders the callInitiatedPanel panel
    initiateCallPanel : function(cmp, attributes) {
        console.log("YOU HAVE REACHED THE END OF PHONE PANEL NOW TRANSFERING TO CALL INITIATED")
        
        attributes.presence = cmp.get('v.presence');
        attributes.careline = 'true';

		
        cmp.getEvent('renderPanel').setParams({
            type : 'c:callInitiatedPanel',
            attributes : attributes
        }).fire();
    },   
    
    
    
    loginCheck : function(cmp) {
        
        
        //KEEP CHECKING FOR VICIDIAL STATUS AND WILL RETURN TO PHONEPANEL AFTER CONFIRM THAT THE STATUS IS CORRECT
        try{
	  var expectedStatus = cmp.get('v.presence');
      var expectedStatus_Translated ="";
      var pauseCode =cmp.get('v.pausecode');
	  var count = cmp.get('v.count');
         count++;
          cmp.set('v.count',count);

            
            if(expectedStatus == "Paused" ){
                expectedStatus_Translated = "PAUSED";
            }
            else{
                expectedStatus_Translated= "CLOSER";
            }
                  console.log(expectedStatus);
            console.log(expectedStatus_Translated);
const xhr = new XMLHttpRequest();
 let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/1/'+cmp.get('v.userCred');
                        console.log(cmp.get('v.userCred'));
xhr.open('GET', url, true);



xhr.onload = () => {
  if (xhr.readyState === xhr.DONE) {
    if (xhr.status === 200) {
      console.log(xhr.responseText);
    
    if(xhr.responseText.includes("NOT")){
        clearTimeout(this.waitingTime);

          console.log(" VICIDIAL SIGNED OUT DETECTED");
                cmp.getEvent('renderPanel').setParams({
                    type: 'c:ctiLoginPanel'
                }).fire();
    
} 
            else if(count == 5){
        this.LightningConfirm.open({
            message: 'Poor Connection Between Salesforce and TDCX, Please Referesh Salesforce',
            variant: 'headerless',
            label: 'Poor Connection',
        }).then(function(result) {
            // result is input value if clicked "OK"
            // result is null if clicked "Cancel"
            console.log('prompt result is', result);
        });    
                 cmp.set('v.LoadingText',"Change Status Failed, Please Referesh Page.");
            }
        else if (xhr.responseText.includes(expectedStatus_Translated)){
                    clearTimeout(this.waitingTime);
			
            if (cmp.get('v.careline')== "true"){
           	cmp.getEvent('renderPanel').setParams({
            type : 'c:phonePanelCare',
            toast : {'type': 'normal', 'message': 'Status Changed Successfully into' + expectedStatus},
            attributes : { presence : expectedStatus,
                          pausecode : pauseCode,
                          userCred : cmp.get('v.userCred')}
        	}).fire();
            }
            else{
            cmp.getEvent('renderPanel').setParams({
            type : 'c:phonePanel',
            toast : {'type': 'normal', 'message': 'Status Changed Successfully into' + expectedStatus},
            attributes : { presence : expectedStatus,
                          pausecode : pauseCode,
                          userCred : cmp.get('v.userCred')}
        	}).fire();
            }

            
        }
        
        
    else {
    console.log("CURRENT STATE NOT MATCH")
            this.waitingTime =setTimeout($A.getCallback(() => this.loginCheck(cmp)), 3000);

    }
    }
  }
};

xhr.send(null);

}

catch (ex) {
console.log('Exception: '+ex);
    
}

        
    },
    
    //CHECK CONSTANTLY IF AVAILABLE
    
            checkStatus: function (cmp, event, helper,result,onCompletion) {
            console.log("result :");   
			console.log(cmp.get('v.presence'));
                if (cmp.get('v.presence') == "Available"){
                        
            try{

const xhr = new XMLHttpRequest();
let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/1/'+cmp.get('v.userCred');
xhr.open('GET', url, true);



xhr.onload = () => {
  if (xhr.readyState === xhr.DONE) {
    if (xhr.status === 200) {

      console.log(xhr.response);
      console.log(xhr.responseText);
    
    //IF SALESFORCE IS AVAIALBLE BUT VICIDIAL IS PAUSED
    if(xhr.responseText.includes("PAUSED")){
    		const Http = new XMLHttpRequest();
            const url='https://apps.tdcx.com.my/SalesforceTest/api/values/3/'+cmp.get('v.userCred');
            Http.open("GET", url);
            Http.send();
}
    if(xhr.responseText.includes("INCALL")){
    clearTimeout(this.waitingTime);

    //FUNCTION FOR POPUP?
    const myArray = xhr.responseText.split(",");
    console.log(myArray[17]);
	var inputValue = myArray[17];
     cmp.set('v.searchResults', []);
    var args = {
            apexClass : 'SoftphoneContactSearchController',
            methodName : 'getContacts',
            methodParams : 'name=' + inputValue,
            callback : function(result) {
                if (result.success) {
                    var searchResults = JSON.parse(result.returnValue.runApex);
    				console.log("searchResults :");
                    console.log(searchResults);
                    cmp.set('v.searchResults', searchResults);
                    if (searchResults.length == 0) {
                        cmp.set('v.message', 'No results found');
                    }
                    onCompletion && onCompletion(cmp, inputValue);
        				//callPhone START HERE
					        var attributes = {
                            'state' : 'Inbound',
                            'recordName' : inputValue
                        };
                    if (searchResults.length != 0) {
                        var record = cmp.get('v.searchResults')
                                && cmp.get('v.searchResults')[0];
                		       var target = record.Phone.replace(/\D/g,'')
        					 var resultss=  inputValue.replace(/\D/g,'') == target && target.length > 0;
                        if (record && resultss) {
                            attributes.recordName = record.Name;
                            attributes.phone = record.Phone;
                            attributes.title = record.Title;
                            attributes.account = record.Account;
                            attributes.recordId = record.Id;
                        };
                        
                    }
                      attributes.userCred = cmp.get('v.userCred');

                        attributes.phone = myArray[17];
                            attributes.careline = 'true';


                        attributes.presence = cmp.get('v.presence');
        cmp.getEvent('renderPanel').setParams({
            type : 'c:callInitiatedPanel',
            attributes : attributes
        }).fire();

                } else {
                    throw new Error('Unable to perform a search using Open CTI. Contact your admin.');
                }
            }
        };
        sforce.opencti.runApex(args);
//END OF SEARCH

    
}
    }
  }
};

xhr.send(null);



this.waitingTime =setTimeout($A.getCallback(() => this.checkStatus(cmp, event, helper,result, onCompletion)), 5000);
}
catch (ex) {
console.log('Exception: '+ex);
}
            
        }

        else{
           clearTimeout(this.waitingTime);
            this.waitingTime =setTimeout($A.getCallback(() => this.checkStatus(cmp, event, helper,result, onCompletion)), 5000);

        }

          },
              

})