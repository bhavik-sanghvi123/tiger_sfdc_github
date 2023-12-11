/*
Copyright 2016 salesforce.com, inc. All rights reserved.

Use of this software is subject to the salesforce.com Developerforce Terms of Use and other applicable terms that salesforce.com may make available, as may be amended from time to time. You may not decompile, reverse engineer, disassemble, attempt to derive the source code of, decrypt, modify, or create derivative works of this software, updates thereto, or any part thereof. You may not use the software to engage in any development activity that infringes the rights of a third party, including that which interferes with, damages, or accesses in an unauthorized manner the servers, networks, or other properties or services of salesforce.com or any third party.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL SALESFORCE.COM HAVE ANY LIABILITY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES, OR DAMAGES BASED ON LOST PROFITS, DATA OR USE, IN CONNECTION WITH THE SOFTWARE, HOWEVER CAUSED AND, WHETHER IN CONTRACT, TORT OR UNDER ANY OTHER THEORY OF LIABILITY, WHETHER OR NOT YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*/

({
    // get call center settings, to get the information about the call provider
    // then use open CTI to screen pop to the record, and runApex() to make a call
    screenPopAndCall : function(cmp) {

        cmp.getEvent('getSettings').setParams({
            callback: function(settings) {
                sforce.opencti.screenPop({
                    type : sforce.opencti.SCREENPOP_TYPE.SOBJECT,
                    params : { recordId : cmp.get('v.recordId') },
                    callback : function(response) {
                        cmp.getEvent('editPanel').setParams({
                            label : 'Open CTI Softphone: ' + cmp.get('v.state')
                        }).fire();
                        var providerClass = settings['/reqPhoneDemoSettings/reqProvider'];
                        var account = settings['/reqPhoneDemoSettings/reqProviderAccount'];
                        var token = settings['/reqPhoneDemoSettings/reqProviderAuthToken'];
                        var fromNumber = settings['/reqPhoneDemoSettings/reqProviderCallerNumber'];
                        var toNumber = cmp.get('v.phone');
                        console.log('CURRENT TITLE IS : ');
                        console.log(cmp.get('v.title'));
                        console.log('CURRENT PHONE NUMBER IS : ');
                        console.log(cmp.get('v.phone'));
                        sforce.opencti.runApex({
                            apexClass : 'SoftphoneProviderController',
                            methodName : 'call',
                            methodParams : 'providerClass=' + providerClass + '&account=' + account + '&token='+ token + '&fromNumber=' + fromNumber + '&toNumber=' + toNumber,
                            callback : function(result) {
                                if (result.success) {
                                    if(toNumber == cmp.get('v.recordName')){
                                        console.log("TRIGGER SCREENPOP FOR NEW CONTACTS")
                                        sforce.opencti.screenPop({
                                        type :sforce.opencti.SCREENPOP_TYPE.URL,
                                        params : { url : "/one/one.app#eyJjb21wb25lbnREZWYiOiJjOkhvdXNlaG9sZEFuZENvbnRhY3RDcmVhdGlvblBhZ2UiLCJhdHRyaWJ1dGVzIjp7InByaW1hcnlDb250YWN0Ijp7InNvYmplY3RUeXBlIjoiQ29udGFjdCJ9fSwic3RhdGUiOnt9fQ%3D%3D",
                                                  Mobile : toNumber
                                                 },
                                    });
                                       
                                    }
                                    
                                } else {
                                    throw new Error('Unable to make a call. Contact your admin.');
                                }
                            }
                        });
                    }
                })
             }
        }).fire();
    },
            searchID : function(cmp,value) {
        console.log("-------------Search ID START HERE -----------");
           console.log("RESULT SEE HERE :");
        var args = {
            apexClass : 'SoftphoneContactSearchController',
            methodName : 'getReason',
            methodParams : 'name='+ value,
            callback : function(result) {
                if (result.success) {
                    var searchResults = JSON.parse(result.returnValue.runApex);
                    console.log(searchResults);
                    var concertName = searchResults[0].Status;
				    console.log(concertName);
                    cmp.set('v.searchTypeID', searchResults);
                    console.log("---------SearchTypeID-----------");
                    console.log(cmp.get('v.searchTypeID'));
                    if (searchResults.length == 0) {

                    }
                } else {
                    throw new Error('Unable to perform a search using Open CTI. Contact your admin.');
                }
            }
        };
        sforce.opencti.runApex(args);
    },
        search : function(cmp, inputValue, onCompletion) {
            console.log("RESULT SEE HERE :");
        var args = {
            apexClass : 'SoftphoneContactSearchController',
            methodName : 'getCustomerCase',
            methodParams : 'name=' + inputValue,
            callback : function(result) {
                if (result.success) {
                    var searchResults = JSON.parse(result.returnValue.runApex);
                    console.log(searchResults);
                    var concertName = searchResults[0].Status;
				    console.log(concertName);
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
        searchName : function(cmp, inputValue, onCompletion) {
            console.log("RESULT SEE HERE :");
        cmp.set('v.searchResults', []);
        var args = {
            apexClass : 'SoftphoneContactSearchController',
            methodName : 'getUserContacts',
            methodParams : 'name=' + inputValue,
            callback : function(result) {
                if (result.success) {
                    var searchResults = JSON.parse(result.returnValue.runApex);
                    console.log(searchResults);
                    var concertName = searchResults[0].Status;
				    console.log(concertName);
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
    
       CheckHangup : function(cmp) {
                    

            const xhr = new XMLHttpRequest();
            let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/1/'+cmp.get('v.userCred');
            
            xhr.open('GET', url, true);
            
            
            
            xhr.onload = () => {
              if (xhr.readyState === xhr.DONE) {
                if (xhr.status === 200) {
            
                  console.log(xhr.response);
                  console.log(xhr.responseText);
                if(xhr.responseText.includes("DEAD")){
                clearTimeout(this.waitingTime);
                cmp.set('v.state2','Customer ');
                cmp.set('v.phone2','HungUp');
                }
                    else if(xhr.responseText.includes("INCALL")){
                        cmp.set('v.conditionCalled','true');
              
                        
                    }
                        else if(xhr.responseText.includes("PAUSED")){
                            
                        cmp.set('v.Condition2','true');
                            
                        }
            
            else {
            }
                }
              }
            };
            
            xhr.send(null);
            this.waitingTime =setTimeout($A.getCallback(() => this.CheckHangup(cmp)), 5000);
          
},
    

    
    
    //END BUTTON FOR INBOUND?
            OutboundWrapup : function(cmp,result,surv_result){
                     

	        console.log("THE RESULT OF called IS :");
            console.log(cmp.get('v.called'));
            
            if (cmp.get('v.called')=="default"){
               clearTimeout(this.waitingTime);

            }
             
            else if(cmp.get('v.transferState')=="true"){

                
             cmp.set("v.Enddisable",true);
             console.log("DELAY TRIGGERED");
            cmp.set("v.called","Wrapup");
             cmp.set("v.recordName","WrapUp");
            cmp.set("v.title","Please Wait for 40 second");
             cmp.set("v.state","Inbound");
                
                 let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/93/'+cmp.get('v.userCred');
  
                Http.open("GET", url);
                Http.send();
            	console.log(Http.responseText);
			    this.waitingTime =setTimeout($A.getCallback(() => this.OutboundWrapup(cmp,result,surv_result)), 2000);
				
        }
       else if(cmp.get('v.called')=="called"){
  
             cmp.set("v.Enddisable",true);
             console.log("DELAY TRIGGERED");
            cmp.set("v.called","Wrapup");
             cmp.set("v.recordName","WrapUp");
            cmp.set("v.title","Please Wait for 40 second");
             cmp.set("v.state","Inbound");
            const Http = new XMLHttpRequest();
           
                let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/97/'+cmp.get('v.userCred');
                if(surv_result=="No") {
                    console.log("SURVEY VALUE DETECTED :");
                    console.log("NO!");
                }
                else{
                    console.log("SURVEY VALUE DETECTED :");
                    console.log(surv_result);
                	url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/110/'+cmp.get('v.userCred')+"-"+surv_result;
                   	console.log(url);
                }                    
           		Http.open("GET", url);
                Http.send();
			    this.waitingTime =setTimeout($A.getCallback(() => this.OutboundWrapup(cmp,result,surv_result)), 2000);
				
        }
           else if(cmp.get('v.called')=="Wrapup"){
                
               console.log("Wrapup Detected");
                const Http = new XMLHttpRequest();
               let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/96/'+cmp.get('v.userCred');
                Http.open("GET", url);
                Http.send();
               cmp.set("v.called","notcalled");
               this.waitingTime =setTimeout($A.getCallback(() => this.OutboundWrapup(cmp,result,surv_result)), 18000);
           }
        else{  
            clearTimeout(this.waitingTime);
            
		const Http = new XMLHttpRequest();
        let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/3/'+cmp.get('v.userCred');
        Http.open("GET", url);
        Http.send();


            
        cmp.getEvent('renderPanel').setParams({
            type : 'c:phonePanel',
            toast : {'type': 'normal', 'message': 'Call was ended.'},
            attributes : { presence : "Available",
                          pausecode : "NoPauseCOde",
                          userCred : cmp.get('v.userCred')}
        }).fire();}

    },
    
    
    //END BUTTON FOR OUTBOUND
        endcall : function(cmp,result,surv_result){
            

	        console.log("THE RESULT OF called IS :");
            console.log(cmp.get('v.called'));
            console.log(cmp.get('v.transferState'));
            if(cmp.get('v.transferState')!="false" && cmp.get('v.transferState')!="true"){
              cmp.set("v.called","called");
              cmp.set("v.careline","false");

            }
           	
            if (cmp.get('v.called')=="default"){
               clearTimeout(this.waitingTime);
				 console.log("CHECKPOINT 1");  
            }
              else if(cmp.get('v.transferState')=="true"){
                  
                 

                  
            clearTimeout(this.waitingTime);
            cmp.set("v.Enddisable",true);
           console.log("DELAY TRIGGERED");
            cmp.set("v.called","Wrapup");
            cmp.set("v.recordName","WrapUp");
            cmp.set("v.title","Please Wait for 40 second");
            cmp.set("v.state","Dialing");
            const Http = new XMLHttpRequest();
          //Check if need to send to survey or not
             let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/93/'+cmp.get('v.userCred');

                Http.open("GET", url);
                Http.send();
            	console.log(Http.responseText);
			    this.waitingTime =setTimeout($A.getCallback(() => this.endcall(cmp,result,surv_result)), 2000);
				
        } 
       else if(cmp.get('v.called')=="called" && cmp.get('v.careline')=="false"){


                const Http2 = new XMLHttpRequest();

                let url2 = 'https://apps.tdcx.com.my/SalesforceTest/api/values/97/'+cmp.get('v.userCred');

                if(surv_result=="No") {
                    console.log("SURVEY VALUE DETECTED :");
                    console.log("NO!");
                }
                else{
                    console.log("SURVEY VALUE DETECTED :");
                    console.log(surv_result);
                	url2 = 'https://apps.tdcx.com.my/SalesforceTest/api/values/110/'+cmp.get('v.userCred')+"-"+surv_result;

                }    
                Http2.open("GET", url2);
                Http2.send();
            	console.log(Http2.responseText);
           
           							const xhr = new XMLHttpRequest();
                           let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/1/'+cmp.get('v.userCred');
							xhr.open('GET', url, true);
                xhr.onload = () => {
                  if (xhr.readyState === xhr.DONE) {
                    if (xhr.status === 200) {
                    
                    if(xhr.responseText.includes("DEAD")||xhr.responseText.includes("PAUSED")){
                   
           clearTimeout(this.waitingTime);
             cmp.set("v.Enddisable",true);
             console.log("DELAY TRIGGERED");
             cmp.set("v.called","dispo");
             cmp.set("v.dispositionAFK","true");
             cmp.set("v.recordName","Disposition");
             cmp.set("v.title","You have 60 second");
             cmp.set("v.state","Dialing");
             cmp.set("v.dispo","dispo");
			    this.waitingTime =setTimeout($A.getCallback(() => this.endcall(cmp,result,surv_result)), 60000);

                    }
                    else {
			    this.waitingTime =setTimeout($A.getCallback(() => this.endcall(cmp,result,surv_result)), 3000);

               			 }
                
                
                
                                }
                                }
                                };
                
                xhr.send(null);



           

        }
           else if(cmp.get('v.called')=="called" && cmp.get('v.careline')=="true"){
           clearTimeout(this.waitingTime);

			
                const Http2 = new XMLHttpRequest();

                let url2 = 'https://apps.tdcx.com.my/SalesforceTest/api/values/97/'+cmp.get('v.userCred');

                if(surv_result=="No") {
                    console.log("SURVEY VALUE DETECTED :");
                    console.log("NO!");
                }
                else{
                    console.log("SURVEY VALUE DETECTED :");
                    console.log(surv_result);
                	url2 = 'https://apps.tdcx.com.my/SalesforceTest/api/values/110/'+cmp.get('v.userCred')+"-"+surv_result;
                 	console.log(url2);

                }    
                Http2.open("GET", url2);
                Http2.send();
            	console.log(url2);
 


               
           							const xhr = new XMLHttpRequest();
                           let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/1/'+cmp.get('v.userCred');
							xhr.open('GET', url, true);
                xhr.onload = () => {
                  if (xhr.readyState === xhr.DONE) {
                    if (xhr.status === 200) {
                    
                    if(xhr.responseText.includes("DEAD")||xhr.responseText.includes("PAUSED")){
                   
           clearTimeout(this.waitingTime);
               const Httpwrapup = new XMLHttpRequest();
                let urlwrapup = 'https://apps.tdcx.com.my/SalesforceTest/api/values/96/'+cmp.get('v.userCred');
                Httpwrapup.open("GET", urlwrapup);
                Httpwrapup.send();
            	console.log(urlwrapup);
             cmp.set("v.Enddisable",true);
             console.log("DISPOSITION TRIGGERED");
           	 cmp.set("v.called","Wrapup");
             cmp.set("v.ConditionCarelineSkip","true");
             cmp.set("v.recordName","WrapUp");
             cmp.set("v.title","Please Wait for 40 second");
             cmp.set("v.state","Dialing");
             cmp.set("v.dispo","No");
             this.waitingTime =setTimeout($A.getCallback(() => this.endcall(cmp,result,surv_result)), 2000);

                    }
                    else {
             this.waitingTime =setTimeout($A.getCallback(() => this.endcall(cmp,result,surv_result)), 2000);

               			 }
                
                
                
                                }
                                }
                                };
                
                xhr.send(null);

               
               
               
               
				
        }
           else if(cmp.get('v.called')=="dispo"){
			console.log("UPDATING CASE LOG....."); 
			console.log("Please Wait.....");        
               
                var caseid = cmp.get('v.caseid');
       var e = document.getElementById("selectType");
        value = e.value;
        var text = e.options[e.selectedIndex].text;
		text = text.replace("Uncontactable - ", "");
       var r = document.getElementById("selectReason");
        reason = r.value;
                         cmp.set("v.sldispoValue","COMPLE");

               console.log("REASON SELECTED IS")
               console.log(value);
               var ownerID = cmp.get('v.ownerID');
               console.log("THE OWNER ID CHANGE IS ");
               console.log(ownerID);

        if(value =="Successful Reason"){

	const Http = new XMLHttpRequest();
        	let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/1004/'+cmp.get('v.userCred');
        console.log(url);
            Http.open("GET", url);
            Http.send();
               console.log("Saving Log Successful");
                  sforce.opencti.saveLog({
                  value : {
                    entityApiName : 'Case',
                      Id:caseid,
                      OwnerId : ownerID,
                    CallOutcome__c  : "Successful",
                    Status  : "Completed",
                      SuccessfulReason__c : reason
        
                    
                  },callback : function(response) {
                        if (response.success) {
    					cmp.set('v.Condition3','false');
                        console.log('API method call executed successfully! returnValue:', response.returnValue);
                        } else {
                        console.error('Something went wrong! Errors:', response.errors);
                        }
                        } 
                    });                
         		}
               else if(cmp.get('v.dispositionAFK')=="true"){
               cmp.set("v.sldispoValue","Follow");
               console.log("Saving Log Uncontactable");
			const Http = new XMLHttpRequest();
        	let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/1001/'+cmp.get('v.userCred');
        	console.log(url);
            Http.open("GET", url);
            Http.send();
                  sforce.opencti.saveLog({
                  value : {
                    entityApiName : 'Case',
                    Id:caseid,
                    OwnerId : ownerID,
                    Status  : "Follow-Up Call Required"        
                    
                  },callback : function(response) {
                        if (response.success) {
    					cmp.set('v.Condition3','false');
                        console.log('API method call executed successfully! returnValue:', response.returnValue);
                        } else {
                        console.error('Something went wrong! Errors:', response.errors);
                        }
                        } 
                    });   
               }
               else if(value =="Unsuccessful Reason"){

               console.log("Saving Log Unsuccesful");
	const Http = new XMLHttpRequest();
        	let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/1004/'+cmp.get('v.userCred');
        console.log(url);
            Http.open("GET", url);
            Http.send();
                  sforce.opencti.saveLog({
                  value : {
                    entityApiName : 'Case',
                      Id:caseid,
                      OwnerId : ownerID,
                    CallOutcome__c  : "Unsuccessful",
                    Status  : "Completed",
                      UnsuccessfulReason__c : reason
        
                    
                  },callback : function(response) {
                        if (response.success) {
    					cmp.set('v.Condition3','false');

                        console.log('API method call executed successfully! returnValue:', response.returnValue);
                        } else {
                        console.error('Something went wrong! Errors:', response.errors);
                        }
                        } 
                    });    
               }
          else if(value =="Uncontactable Reason" && text=="Completed"){
                                            cmp.set("v.sldispoValue","Follow");

               console.log("Saving Log Uncontactable COMPLETED");
	const Http = new XMLHttpRequest();
        	let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/1004/'+cmp.get('v.userCred');
        console.log(url);
            Http.open("GET", url);
            Http.send();
                  sforce.opencti.saveLog({
                  value : {
                    entityApiName : 'Case',
                      Id:caseid,
                      OwnerId : ownerID,
                    CallOutcome__c  : "Uncontactable",
                    Status  : "Completed",
                      UncontactableReason__c : reason
        
                    
                  },callback : function(response) {
                        if (response.success) {
    					cmp.set('v.Condition3','false');
                        console.log('API method call executed successfully! returnValue:', response.returnValue);
                        } else {
                        console.error('Something went wrong! Errors:', response.errors);
                        }
                        } 
                    });    
               }
               else if(value =="Uncontactable Reason" && text=="Manual Call back immediately"){
               cmp.set("v.sldispoValue","Follow");
               console.log("Saving Log Uncontactable");
			const Http = new XMLHttpRequest();
        	let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/1004/'+cmp.get('v.userCred');
        	console.log(url);
            Http.open("GET", url);
            Http.send();
                  sforce.opencti.saveLog({
                  value : {
                    entityApiName : 'Case',
                    Id:caseid,
                    OwnerId : ownerID,
                    Status  : "Follow-Up Call Required"        
                    
                  },callback : function(response) {
                        if (response.success) {
    					cmp.set('v.Condition3','false');
                        console.log('API method call executed successfully! returnValue:', response.returnValue);
                        } else {
                        console.error('Something went wrong! Errors:', response.errors);
                        }
                        } 
                    });   
               }
               else if(value =="Uncontactable Reason" && text=="Follow Up Required"){
               cmp.set("v.sldispoValue","Follow");
               console.log("Saving Log Uncontactable");
			//const Http = new XMLHttpRequest();
        	//let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/1001/'+cmp.get('v.userCred');
        	//console.log(url);
           // Http.open("GET", url);
           // Http.send();
                  sforce.opencti.saveLog({
                  value : {
                    entityApiName : 'Case',
                    Id:caseid,
                    OwnerId : ownerID,
                    CallOutcome__c  : "Uncontactable",
                    Status  : "Follow-Up Call Required",
                    UncontactableReason__c : reason
        
                    
                  },callback : function(response) {
                        if (response.success) {
    					cmp.set('v.Condition3','false');
                        console.log('API method call executed successfully! returnValue:', response.returnValue);
                        } else {
                        console.error('Something went wrong! Errors:', response.errors);
                        }
                        } 
                    });    
               }
               else if(value =="Uncontactable Reason" && text=="Pending Second Attempt"){
                cmp.set("v.sldispoValue","2ndAt");

               console.log("Saving Log Uncontactable");
	const Http = new XMLHttpRequest();
        	let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/1002/'+cmp.get('v.userCred');
        console.log(url);
            Http.open("GET", url);
            Http.send();
                  sforce.opencti.saveLog({
                  value : {
                    entityApiName : 'Case',
                      Id:caseid,
                      OwnerId : ownerID,
                    CallOutcome__c  : "Uncontactable",
                    Status  : "Pending Second Attempt",
                      UncontactableReason__c : reason
        
                    
                  },callback : function(response) {
                        if (response.success) {
    					cmp.set('v.Condition3','false');
                        console.log('API method call executed successfully! returnValue:', response.returnValue);
                        } else {
                        console.error('Something went wrong! Errors:', response.errors);
                        }
                        } 
                    });    
               }
               else if(value =="Uncontactable Reason" && text=="Pending Third Attempt"){
          cmp.set("v.sldispoValue","3rdAt");

               console.log("Saving Log Uncontactable");
	const Http = new XMLHttpRequest();
        	let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/1003/'+cmp.get('v.userCred');
        console.log(url);
            Http.open("GET", url);
            Http.send();
                  sforce.opencti.saveLog({
                  value : {
                    entityApiName : 'Case',
                      Id:caseid,
                      OwnerId : ownerID,
                    CallOutcome__c  : "Uncontactable",
                    Status  : "Pending Third Attempt",
                      UncontactableReason__c : reason
        
                    
                  },callback : function(response) {
                        if (response.success) {
    					cmp.set('v.Condition3','false');
                        console.log('API method call executed successfully! returnValue:', response.returnValue);
                        } else {
                        console.error('Something went wrong! Errors:', response.errors);
                        }
                        } 
                    });    
               }
               else if(value =="Invalid Reason"){
               console.log("Saving Log Invalid");
	const Http = new XMLHttpRequest();
        	let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/1004/'+cmp.get('v.userCred');
        console.log(url);
            Http.open("GET", url);
            Http.send();
                  sforce.opencti.saveLog({
                  value : {
                    entityApiName : 'Case',
                      Id:caseid,
                      OwnerId : ownerID,
                    CallOutcome__c  : "Invalid",
                    Status  : "Completed",
                      InvalidReason__c : reason
        
                    
                  },callback : function(response) {
                        if (response.success) {
    					cmp.set('v.Condition3','false');
                        console.log('API method call executed successfully! returnValue:', response.returnValue);
                        } else {
                        console.error('Something went wrong! Errors:', response.errors);
                        }
                        } 
                    });    
               }
               
               
               
               if(value.includes("Uncontactable Reason")){
                   
             cmp.set("v.slCallBack","yes");
             cmp.set("v.dispoDisable",true);
            cmp.set("v.testTime", result);
                 cmp.set("v.Enddisable",true);
             console.log("DISPOSITION TRIGGERED");
           	 cmp.set("v.called","Wrapup");
    	     cmp.set('v.Condition3','false');
             cmp.set("v.recordName","WrapUp");
             cmp.set("v.title","Please Wait for 40 second");
             cmp.set("v.state","Dialing");
             cmp.set("v.dispo","No");
                const Http = new XMLHttpRequest();
               let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/96/'+cmp.get('v.userCred');
                Http.open("GET", url);
                Http.send();
             this.waitingTime =setTimeout($A.getCallback(() => this.endcall(cmp,result,surv_result)), 5000);

               }
               else{
                   result="00-00-00-00-00-00";
              	const Http = new XMLHttpRequest();
                let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/301/'+cmp.get('v.userCred')+'-'+cmp.get('v.sldispoValue');+"-"+result;
                console.log(url);      
                Http.open("GET", url);
                Http.send();
             cmp.set("v.Enddisable",true);
             console.log("DISPOSITION TRIGGERED");
           	 cmp.set("v.called","Wrapup");
    	     cmp.set('v.Condition3','false');
             cmp.set("v.recordName","WrapUp");
             cmp.set("v.title","Please Wait for 40 second");
             cmp.set("v.state","Dialing");
             cmp.set("v.dispo","No");
                const Httpwrapup = new XMLHttpRequest();
               let urlwrapup = 'https://apps.tdcx.com.my/SalesforceTest/api/values/96/'+cmp.get('v.userCred');
                Httpwrapup.open("GET", urlwrapup);
                Httpwrapup.send();
             this.waitingTime =setTimeout($A.getCallback(() => this.endcall(cmp,result,surv_result)), 5000);
               }

           }

           else if(cmp.get('v.called')=="Wrapup"){
               
                const xhr = new XMLHttpRequest();
                let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/1/'+cmp.get('v.userCred');
				xhr.open('GET', url, true);
                xhr.onload = () => {
                  if (xhr.readyState === xhr.DONE) {
                    if (xhr.status === 200) {
                    
                    if(xhr.responseText.includes("PAUSED")){
                   
               console.log("Wrapup Detected");
           	 cmp.set("v.dispositionFreezer","false");
    	     cmp.set('v.Condition3','true');
                const Http2 = new XMLHttpRequest();
               let url2 = 'https://apps.tdcx.com.my/SalesforceTest/api/values/96/'+cmp.get('v.userCred');
                Http2.open("GET", url2);
                Http2.send();
               cmp.set("v.called","notcalled");
               this.waitingTime =setTimeout($A.getCallback(() => this.endcall(cmp,result,surv_result)), 30000);

                    }
                    else {
             this.waitingTime =setTimeout($A.getCallback(() => this.endcall(cmp,result,surv_result)), 2000);

               			 }
                
                
                
                                }
                                }
                                };
                
                xhr.send(null);
           }
        else{  
            clearTimeout(this.waitingTime);
            
		//const Http = new XMLHttpRequest();
        //let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/3/'+cmp.get('v.userCred');
        //Http.open("GET", url);
        //Http.send();
        if(cmp.get('v.careline')=='false'){
            
            console.log("GOING BACK TO TELE");
         cmp.getEvent('renderPanel').setParams({
            type : 'c:phonePanel',
            toast : {'type': 'normal', 'message': 'Call was ended.'},
            attributes : { presence : "Paused",
                          pausecode : "withcode",
                          returnAvailable : "true",
                         userCred : cmp.get('v.userCred')}
        }).fire();
			}
            else{
                console.log("GOING BACK TO CARELINE");
                        cmp.getEvent('renderPanel').setParams({
            type : 'c:phonePanelCare',
            toast : {'type': 'normal', 'message': 'Call was ended.'},
            attributes : { presence : "Available",
                          pausecode : "NoPauseCOde",
                         userCred : cmp.get('v.userCred')}
        }).fire();
            }
        
        }

    },

    // on Accept, accept the call by bringing up the Connected Panel
    renderConnectedPanel : function(cmp){
        
                var recordId = cmp.get('v.recordId');
                var account = cmp.get('v.account');
                cmp.getEvent('renderPanel').setParams({
                    type : 'c:connectedPanel',
                    attributes : {
                        showDialPad : false,
                        recordId : recordId,
                        callType : 'Inbound',
                        account : account,
                        recordName: cmp.get('v.recordName'),
                        presence : cmp.get('v.presence')
                    }
                }).fire();
    },
        
        
      CheckTransfer : function(cmp){
                
                if(cmp.get('v.transferState')=='false'){
                     clearTimeout(this.waitingTime);

                    
                }
                else{
                    console.log("CHECKING IF AGENT HAS HUNG UP")
                    const xhr = new XMLHttpRequest();
                xhr.open('GET', 'https://apps.tdcx.com.my/SalesforceTest/api/values/99/'+cmp.get('v.userCred'), true);
            
            
            
                xhr.onload = () => {
                 let text = xhr.response;
                    const myArray = text.split(",");
                    let length = myArray.length;
            
                  console.log(xhr.response);
                    console.log(myArray.length);
                        for (let i = 0; i < myArray.length; i++) {
                        
                        console.log(myArray.length);
                        }
            
                    let lengthCount = length/10;
                    console.log(lengthCount);
                    let final = " ";
            
                    
                    for (let i = 1; i < lengthCount; i++) {
                        final="";
                        let position = i*10;
                        position = position -i;
                        
                        for (let x = 0; x < 9; x++) {
                        let result = myArray[x+position];
                        result=  result.replace('user_level','');
                        
                        final += result;
                        final += ",";
                        }
                        if(i==1){
                           final = final.slice(2, 1000);
                        }
                        else {final = final.slice(3, 1000);
                             }
                        console.log(final)
                     if(final.includes("PAUSED") && final.includes(cmp.get('v.agentID'))){
                    console.log("AGENT HAS HUNG UP DETECTED")

                         cmp.set('v.state2','Agent ');
                            cmp.set('v.phone2','Not Available');
					
         }
            else{
                
            }
            }
        


        


	};

	xhr.send(null);
                
            this.waitingTime =setTimeout($A.getCallback(() => this.CheckTransfer(cmp)), 2000);
                } 

    },
        
        
        
        
       AgentDropDownbackup : function(cmp){
		       if (cmp.get('v.phone2')=='HungUp' || cmp.get('v.called')=='Wrapup' || cmp.get('v.called')=='default'){
                   
                       clearTimeout(this.waitingTime);


                    }
                    
                else if(cmp.get('v.transferState')=="true"){
                    
                 this.waitingTime =setTimeout($A.getCallback(() => this.AgentDropDown(cmp)), 2000);

                    
                }
            
                else if(cmp.get('v.transferDrop')=="true"){
                    var selectD = document.getElementById("Transfer_Codes");
                    while (selectD.options.length > 0) {                
                        selectD.remove(0);
                    }     
                            cmp.set('v.transferDrop','false');
                            this.waitingTime =setTimeout($A.getCallback(() => this.AgentDropDown(cmp)), 2000);
        
                        }
                else {

                const xhr = new XMLHttpRequest();
                xhr.open('GET', 'https://apps.tdcx.com.my/SalesforceTest/api/values/99/'+cmp.get('v.userCred'), true);
            
            
            
                xhr.onload = () => {
                 let text = xhr.response;
                    const myArray = text.split(",");
                    let length = myArray.length;
            
                  console.log(xhr.response);
                    console.log(myArray.length);
                        for (let i = 0; i < myArray.length; i++) {
                        
                        console.log(myArray.length);
                        }
            
                    let lengthCount = length/10;
                    console.log(lengthCount);
                    let final = " ";
            
                    
                    for (let i = 1; i < lengthCount; i++) {
                        final="";
                        let position = i*10;
                        position = position -i;
                        
                        for (let x = 0; x < 9; x++) {
                        let result = myArray[x+position];
                        result=  result.replace('user_level','');
                        
                        final += result;
                        final += ",";
                        }
                        if(i==1){
                           final = final.slice(2, 1000);
                        }
                        else {final = final.slice(3, 1000);
                             }
                        
                     if(final.includes("CLOSER")){
                    const myFinalArray = final.split(","); 
                    var option = document.createElement("option");
                    option.text = myFinalArray[0]+" | "+myFinalArray[7];
                    option.value = myFinalArray[0];
                    var select = document.getElementById("Transfer_Codes");
                    select.appendChild(option);
                    console.log(final);
         }
            else{
                
            }
            }
        


        


	};

	xhr.send(null);
                cmp.set('v.transferDrop','true');
            this.waitingTime =setTimeout($A.getCallback(() => this.AgentDropDown(cmp)), 2000);

	}	
    }
})