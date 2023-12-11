/*
	Copyright 2016 salesforce.com, inc. All rights reserved.

	Use of this software is subject to the salesforce.com Developerforce Terms of Use and other applicable terms that salesforce.com may make available, as may be amended from time to time. You may not decompile, reverse engineer, disassemble, attempt to derive the source code of, decrypt, modify, or create derivative works of this software, updates thereto, or any part thereof. You may not use the software to engage in any development activity that infringes the rights of a third party, including that which interferes with, damages, or accesses in an unauthorized manner the servers, networks, or other properties or services of salesforce.com or any third party.

	WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL SALESFORCE.COM HAVE ANY LIABILITY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES, OR DAMAGES BASED ON LOST PROFITS, DATA OR USE, IN CONNECTION WITH THE SOFTWARE, HOWEVER CAUSED AND, WHETHER IN CONTRACT, TORT OR UNDER ANY OTHER THEORY OF LIABILITY, WHETHER OR NOT YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
	*/

	({
		// enable click to dial, and bring up the phone panel.
		handleLogin : function(cmp,finalValue) {

const xhr = new XMLHttpRequest();

            let url = "https://apps.tdcx.com.my/SalesforceTest/api/values/1/"+finalValue;
            console.log(url);
xhr.open('GET', url, true);



xhr.onload = () => {
  if (xhr.readyState === xhr.DONE) {
    //if (xhr.status === 200) {

      console.log(xhr.response);
      console.log(xhr.responseText);
        var e = document.getElementById("VD_campaign");
        value = e.value;
    if(xhr.responseText.includes("callerid")){
    if(value== "ABOT_TEL"){
              console.log(" LOGGED IN DETECTED");
			sforce.opencti.enableClickToDial({callback: function() {
				cmp.getEvent('renderPanel').setParams({
					type : 'c:phonePanel',
					attributes: { presence : 'Paused',
    								userCred : finalValue}
				}).fire();
			}
		  });
			console.log("---Launch into phonepanel FOR TELE----")
}
else{
              console.log(" LOGGED IN DETECTED");
			sforce.opencti.enableClickToDial({callback: function() {
				cmp.getEvent('renderPanel').setParams({
					type : 'c:phonePanelCare',
					attributes: { presence : 'Paused',
    								userCred : finalValue}
				}).fire();
			}
		  });
			console.log("---Launch into phonepanel FOR CARELINE----")
}

    
}
else {
cmp.getEvent('renderPanel').setParams({
                    type: 'c:ctiLoginPanel',
     				toast : {'type': 'normal', 'message': 'Agent Vicidial login not detected'},
                    attributes : {
                            State : 'Salesforce',
    						
                        }
                }).fire();
    		
}

//}
  }
};

xhr.send(null);






               								

        

		},


            
			NewContacts : function(cmp, event, helper) {
				var Text = "Account";
				var searchResults = JSON.parse("0035g00000cQpN7AAK")
	  sforce.opencti.screenPop({
											type : sforce.opencti.SCREENPOP_TYPE.SOBJECT,
											params : { recordId : searchResults },
										});
				
		},
          
        autoCheck: function(cmp, event, helper) {

        try{

const xhr = new XMLHttpRequest();

            let url = "https://apps.tdcx.com.my/SalesforceTest/api/values/1/"+finalValue;
xhr.open('GET', url, true);



xhr.onload = () => {
  if (xhr.readyState === xhr.DONE) {
    if (xhr.status === 200) {

      console.log(xhr.response);
      console.log(xhr.responseText);
    
    if(xhr.responseText.includes("callerid")){
          console.log(" LOGGED IN DETECTED");
                cmp.getEvent('renderPanel').setParams({
                    type: 'c:ctiLoginPanel',
                    attributes : {
                            State : 'Salesforce',
    						
                        }
                }).fire();
    
}
else {


console.log("CURRENT STATE NOT LOGGED IN")
cmp.getEvent('renderPanel').setParams({
                    type: 'c:ctiLoginPanel',
                    attributes : {
                            State : 'Vicidial',
   							 Likedisable : false
                        }
                }).fire();

    		
}
if(cmp.get('v.autoStop')=="Checking"){    	
    this.waitingTime =setTimeout($A.getCallback(() => this.autoCheck(cmp, event, helper)), 1000);
		}
else {
                clearTimeout(this.waitingTime);

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
		
		
		testHelper : function(cmp, event, helper) {
		console.log("Button CLicked: ")
		this.waitingTime =setTimeout($A.getCallback(() => this.Wrapup(cmp, event, helper)), 4000);
			
		},
			Wrapup : function(cmp, event, helper) {
			console.log("Wrapup Function: ")
			cmp.set('v.Test',"SUCCESS");
			clearTimeout(this.waitingTime);
			
		},
		
			Storage : function(cmp, event, helper) {
	try{

	const xhr = new XMLHttpRequest();

            let url = "https://apps.tdcx.com.my/SalesforceTest/api/values/1/"+finalValue;
	xhr.open('GET', url, true);



	xhr.onload = () => {
	  if (xhr.readyState === xhr.DONE) {
		if (xhr.status === 200) {
			
		  console.log(xhr.response);
		  console.log(xhr.responseText);
		if(xhr.responseText.includes("NOT LOGGED IN")){
			  console.log("NOT LOGGED IN DETECTED");
			  cmp.set("v.state","Vicidial");
				cmp.set("v.Likedisable","false");
	this.waitingTime =setTimeout($A.getCallback(() => this.Storage(cmp, event, helper)), 5000);

		
	}
	else {
					clearTimeout(this.waitingTime);

		console.log("LOGGED IN DETECTED");
			  cmp.set("v.state","Salesforce");
				
	}
		}
	  }
	};

	xhr.send(null);

	}

	catch (ex) {
	console.log('Exception: '+ex);
	}

	 


		}
			
	})