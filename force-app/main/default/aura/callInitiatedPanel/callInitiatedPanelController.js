/*
Copyright 2016 salesforce.com, inc. All rights reserved.

Use of this software is subject to the salesforce.com Developerforce Terms of Use and other applicable terms that salesforce.com may make available, as may be amended from time to time. You may not decompile, reverse engineer, disassemble, attempt to derive the source code of, decrypt, modify, or create derivative works of this software, updates thereto, or any part thereof. You may not use the software to engage in any development activity that infringes the rights of a third party, including that which interferes with, damages, or accesses in an unauthorized manner the servers, networks, or other properties or services of salesforce.com or any third party.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL SALESFORCE.COM HAVE ANY LIABILITY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES, OR DAMAGES BASED ON LOST PROFITS, DATA OR USE, IN CONNECTION WITH THE SOFTWARE, HOWEVER CAUSED AND, WHETHER IN CONTRACT, TORT OR UNDER ANY OTHER THEORY OF LIABILITY, WHETHER OR NOT YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*/

({
    // screen pop to the contact home, and use the call provider to make a call
    init : function(cmp, event, helper) {
		        var args = {
            apexClass : 'SoftphoneContactSearchController',
            methodName : 'getOwnerID',
            methodParams : 'name=test',
            callback : function(result) {
                if (result.success) {
                    var searchResults = result.returnValue.runApex;
                    cmp.set('v.ownerID',searchResults);
                    console.log("searchResults FOR OWNER ID IS ");
                    console.log(searchResults);
                    
                } else {
                    throw new Error('Unable to perform a search using Open CTI. Contact your admin.');
                }
            }
        };
        sforce.opencti.runApex(args);
		console.log(cmp.get('v.userCred'));
        console.log("Careline is :"+cmp.get('v.careline'));
		console.log(cmp.get('v.callbackTrigger'));
        helper.screenPopAndCall(cmp);
        if(cmp.get('v.presence')=="Available"){
            cmp.set('v.state2',cmp.get('v.state'));
          }
        else {
            cmp.set('v.state2',' ');
            cmp.set('v.flavorText',' ');
        }

        cmp.set('v.phone2',cmp.get('v.phone'));
        helper.CheckHangup(cmp);
		console.log(cmp.get('v.presence'));
        if(cmp.get('v.presence')=="Available"){	
        cmp.set('v.called','called');
		//helper.AgentDropDown(cmp);
        cmp.set('v.ButtonText','End')

	}
        if(cmp.get('v.callbackTrigger')=="yes"){
			cmp.set("v.Likedisable",true);
            cmp.set("v.called","called");
            cmp.set("v.ButtonText","End");
     		cmp.set("v.lastPresence","Paused");
     		cmp.set("v.tickerDisable",false);
     		cmp.set('v.state2',"Inbound");
     		cmp.set("v.flavorText","...");
            //console.log("THE RESULT OF called IS :");
            //console.log(cmp.get('v.called'));
     		console.log("Record Name :");
     		console.log(cmp.get('v.recordName'));
           	console.log("v.account.Name IS :");
     		console.log(cmp.get('v.account.Name'));
     		console.log("v.account.id IS :");
     		console.log(cmp.get('v.account.Id'));
            console.log("v.recordID IS :");
     		console.log(cmp.get('v.recordId'));
        }
       var number = cmp.get('v.phone');
       if(cmp.get('v.careline')=="false"){
       helper.search(cmp, number, function(cmp, number){ 
        });
        }
        
	 },
    handleSelectCard: function (cmp, event, helper) {
        var index = event.currentTarget.getAttribute('data-value');
        var selectedRecord = cmp.get('v.searchResults')[index];
        cmp.set('v.searchResults', []);
        cmp.set('v.caseid',selectedRecord.Id);
        cmp.set('v.ifcardselected',"true");
    }, 
    changeSelect: function (cmp, event, helper) {
        //Do something with the change handler
        var e = document.getElementById("selectType");
        var value = e.value;
        var text = e.options[e.selectedIndex].text;
        cmp.set('v.Condition2',"true");
        helper.searchID(cmp,value);
        
    },
    testTimeSelect: function(cmp, event, helper) {
                const startTime = document.getElementById("startTime");
                const startDate = document.getElementById("startDate");
                var result = startDate.value;
                         cmp.set("v.dispositionAFK","false");
                   var e = document.getElementById("selectType");
                   var value = "ERROR";
                   var text = e.options[e.selectedIndex].text;
                    text = text.replace("Uncontactable - ", "");
            
                        console.log("Before Value Chosen is");
                        console.log(value);
                    
                    
                    if(text =="Follow Up Required"){
                console.log("TRIGGERED Selected TEXT chosen is ");
                console.log(text);
                        value="Follow"
                    }
                    else if(text =="Pending Second Attempt"){
                            console.log("TRIGGERED Selected TEXT chosen is ");
                console.log(text);
                        value="2ndAt"
            
                    }
                    else if(text =="Pending Third Attempt"){
                            console.log("TRIGGERED Selected TEXT chosen is ");
                console.log(text);
                        value="3rdAt"
            
                    }
                        else {
                                console.log("TRIGGERED Selected TEXT chosen is ");
                console.log(text);
                           value="COMPLE"
                        }
                        console.log("After Dispo Value chosen is ");
                console.log(value);
                 result += "-";
                 result += startTime.value.replace(":", "-");
                 result += "-00";
                const Http = new XMLHttpRequest();
                let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/301/'+cmp.get('v.userCred')+'-'+value+"-"+result;
                console.log(url);      
                Http.open("GET", url);
                Http.send();
                console.log("Selected TEXT chosen is ");
                console.log(text);
                console.log("Time CHOSEN IS");
                console.log(result);
                 helper.endcall(cmp,cmp.get('v.called'),"test");
            
                
     },
    refreshCase: function (cmp, event, helper) {
	cmp.set('v.caseid',"");
    cmp.set('v.ifcardselected',"false");
       var number = cmp.get('v.phone');

       helper.search(cmp, number, function(cmp, number){
            
        });


    }, 
    
    selectReason: function(cmp, evt,helper) {	
        helper.endcall(cmp,cmp.get('v.called'),"test");
		console.log(cmp.get('v.called'));
	 },


    onCheck: function(cmp, evt) {		 
        var checkCmp = cmp.find("checkbox");
		
		 cmp.set("v.checkResult", ""+checkCmp.get("v.value"));

        
        if(cmp.get("v.checkResult") == "true"){
            cmp.set('v.myBool',true);
            cmp.set('v.lastPresence',"Paused");
            console.log("MyBool Attribute :");
            console.log(cmp.get("v.myBool"));
        }
        else {
            console.log("MyBool Attribute :");
             console.log(cmp.get("v.myBool"));
            cmp.set('v.myBool',false)
            cmp.set('v.lastPresence',"Available");
        }
	 },
         
      transfer: function(cmp, event, helper) {
          
          	cmp.set('v.transferState','true');
          	cmp.set("v.ButtonText","Leave 3 Way Call");
          	
          
            var e = document.getElementById("Transfer_Codes");
        	var value = e.value;
          console.log(value);  
          cmp.set("v.agentID",value);
          
			const Http = new XMLHttpRequest();
            let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/94/'+cmp.get('v.userCred')+'-'+value;
          console.log(url);
          
            Http.open("GET", url);
            Http.send();
			//helper.AgentDropDown(cmp);
          helper.CheckTransfer(cmp);
	 },
    
          holdCustomer: function(cmp, event, helper) {
          
              if(cmp.get('v.grabPark')== "Hold Customer"){
                  cmp.set("v.grabPark","Unhold Customer");
                            
			const Http = new XMLHttpRequest();
            let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/91/'+cmp.get('v.userCred');
          	console.log(url);
            Http.open("GET", url);
            Http.send();
              }
              else {
                  cmp.set("v.grabPark","Hold Customer");
                            
			const Http = new XMLHttpRequest();
            let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/90/'+cmp.get('v.userCred');
          	console.log(url);
            Http.open("GET", url);
            Http.send();
              }
          	
          	
        

	 },
       AgentHangup: function(cmp, event, helper) {
          
          	cmp.set('v.transferState','false');
          	cmp.set("v.ButtonText","End");
           	cmp.set("v.transferDrop","false");
          	

			const Http = new XMLHttpRequest();
            let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/92/'+cmp.get('v.userCred');
         	console.log(url);
            Http.open("GET", url);
            Http.send();
           cmp.set('v.transferDrop','true');
			 cmp.set('v.state2',cmp.get('v.state'));
                cmp.set('v.phone2',cmp.get('v.phone'));

	 },

    
 call : function(cmp, event, helper) {
			const Http = new XMLHttpRequest();
     		
            let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/98/'+cmp.get('v.userCred')+'-'+cmp.get('v.phone');
            Http.open("GET", url);
            Http.send();
            
			cmp.set("v.Likedisable",true);
            cmp.set("v.called","called");
            cmp.set("v.ButtonText","End");
     		cmp.set("v.lastPresence","Paused");
     		cmp.set("v.tickerDisable",false);
     		cmp.set('v.state2',cmp.get('v.state'));
     		cmp.set("v.flavorText","...");
            //console.log("THE RESULT OF called IS :");
            //console.log(cmp.get('v.called'));
     		console.log("Record Name :");
     		console.log(cmp.get('v.recordName'));
           	console.log("v.account.Name IS :");
     		console.log(cmp.get('v.account.Name'));
     		console.log("v.account.id IS :");
     		console.log(cmp.get('v.account.Id'));
            console.log("v.recordID IS :");
     		console.log(cmp.get('v.recordId'));
     
			//helper.AgentDropDown(cmp);

    },
    
    // On incoming calls, this is a handler for the Accept button


    // On incoming calls, this is a handler for the Decline button
    // taking you back to the phone panel
    decline : function(cmp, event, helper) {
         var value = "No";
        if(cmp.get('v.state2') != 'Customer '){
        var e = document.getElementById("Survey_Transfer");
        value = e.value;
        }
        //End of call logging
        cmp.set("v.called","called");
        cmp.set('v.state2',' ');
    	cmp.set('v.phone2','Wrapping Up');

        console.log(value);  
		helper.endcall(cmp,cmp.get('v.called'),value);
    },
    
    
    // On dialing calls, this is a handler for the End button
    // taking you back to the phone panel
    end : function(cmp, event, helper) {
        
        cmp.set('v.lastPresence',"Available");
        if(cmp.get('v.ButtonText') == 'Cancel'){
   
           if(cmp.get('v.careline') == 'false'){  
                sforce.opencti.enableClickToDial({callback: function() {
                cmp.getEvent('renderPanel').setParams({
                type : 'c:phonePanel',
                attributes: { presence : 'Paused',
                          userCred : cmp.get('v.userCred')}
            }).fire();
        }
                                                 });}
            else{
                                sforce.opencti.enableClickToDial({callback: function() {
                cmp.getEvent('renderPanel').setParams({
                type : 'c:phonePanelCare',
                attributes: { presence : 'Paused',
                          userCred : cmp.get('v.userCred')}
            }).fire();
        }
                                                 });
            }
        }
        else { 
                     var value = "No";
                    if(cmp.get('v.state2') != 'Customer '){
                    var e = document.getElementById("Survey_Transfer");
                    value = e.value;
                    }
                cmp.set('v.state2',' ');
    			cmp.set('v.phone2','Wrapping Up');
                console.log(value);  
                helper.endcall(cmp,cmp.get('v.called'),value);
             }
       

      
    
          
               
    },
        skip : function(cmp, event, helper) {
            cmp.set("v.called","default");
         cmp.set("v.called","default");
		helper.OutboundWrapup(cmp,cmp.get('v.called'));
         helper.endcall(cmp,cmp.get('v.called'));
            


			console.log("current selected STATE :");
			console.log(cmp.get('v.lastPresence'));
            
        if(cmp.get('v.lastPresence') == "Paused") {
        var e = document.getElementById("Pause_Codes");
        var value = e.value;
        var text = e.options[e.selectedIndex].text;
             

            const xhr = new XMLHttpRequest();
            var url = "https://apps.tdcx.com.my/SalesforceTest/api/values/"+value+"/"+cmp.get('v.userCred');
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

                
            
            if(cmp.get('v.lastPresence') == "Paused") {
                //helper.AgentDropDown(cmp);
    			if(cmp.get('v.careline') == 'false'){  
                    console.log("GOING BACK TO TELE");
                    console.log("Last Status Paused Detected");
              cmp.getEvent('renderPanel').setParams({
            type : 'c:phonePanel',
            toast : {'type': 'normal', 'message': 'WRAPUP SKIPPED'},
            attributes : { presence : "Paused",
                          userCred : cmp.get('v.userCred')}
        }).fire();
    }
    else {
                        console.log("GOING BACK TO CARELINE");
                        console.log("Last Status Paused Detected");
              cmp.getEvent('renderPanel').setParams({
            type : 'c:phonePanelCare',
            toast : {'type': 'normal', 'message': 'WRAPUP SKIPPED'},
            attributes : { presence : "Paused",
                          userCred : cmp.get('v.userCred')}
        }).fire();
    }
}
           
         else {
             //helper.AgentDropDown(cmp);

             console.log("Last Status Available Detected");
    		//const Http = new XMLHttpRequest();
            //const url='https://apps.tdcx.com.my/SalesforceTest/api/values/3/'+cmp.get('v.userCred');
            //Http.open("GET", url);
            //Http.send();
             if(cmp.get('v.careline') == 'false'){  
                console.log("GOING BACK TO TELE");
                           cmp.getEvent('renderPanel').setParams({
            type : 'c:phonePanel',
            toast : {'type': 'normal', 'message': 'WRAPUP SKIPPED'},
            attributes : { presence : "Paused",
                          pausecode : "withcode",
                          returnAvailable : "true",
                         userCred : cmp.get('v.userCred')}
        	}).fire();
             }
             
             else{
            console.log("GOING BACK TO CARELINE");
    		const Http = new XMLHttpRequest();
            const url='https://apps.tdcx.com.my/SalesforceTest/api/values/3/'+cmp.get('v.userCred');
            Http.open("GET", url);
            Http.send();
            cmp.getEvent('renderPanel').setParams({
            type : 'c:phonePanelCare',
            toast : {'type': 'normal', 'message': 'WRAPUP SKIPPED'},
            attributes : { presence : "Available" ,
                          pausecode : "NoPauseCOde",
                          userCred : cmp.get('v.userCred')}
        }).fire();
             }

         }	               
    },       
    

    
    //end
    
})