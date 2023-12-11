/*
Copyright 2016 salesforce.com, inc. All rights reserved.

Use of this software is subject to the salesforce.com Developerforce Terms of Use and other applicable terms that salesforce.com may make available, as may be amended from time to time. You may not decompile, reverse engineer, disassemble, attempt to derive the source code of, decrypt, modify, or create derivative works of this software, updates thereto, or any part thereof. You may not use the software to engage in any development activity that infringes the rights of a third party, including that which interferes with, damages, or accesses in an unauthorized manner the servers, networks, or other properties or services of salesforce.com or any third party.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL SALESFORCE.COM HAVE ANY LIABILITY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES, OR DAMAGES BASED ON LOST PROFITS, DATA OR USE, IN CONNECTION WITH THE SOFTWARE, HOWEVER CAUSED AND, WHETHER IN CONTRACT, TORT OR UNDER ANY OTHER THEORY OF LIABILITY, WHETHER OR NOT YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*/

({
        init : function(cmp, event, helper) {

        helper.autoCheck(cmp, event, helper);

        
    },

    
    // on login
    handleLogin: function(cmp, event, helper) {
        if(document.getElementById("phone_login").value=="" ){console.log("Empty 1")}
        else if(document.getElementById("phone_pass").value==""){console.log("Empty 2")}
        else if(document.getElementById("VD_login").value==""){console.log("Empty 3")}
        else if(document.getElementById("VD_pass").value==""){console.log("Empty 4")}
        else{ 
            console.log("Success")
			let inputValue = document.getElementById("VD_login").value; 
             let inputValue2 = document.getElementById("VD_pass").value;
             let finalValue = inputValue +"-"+inputValue2;
            helper.handleLogin(cmp,finalValue);
        
        }
       
    },
        testTimeSelect: function(cmp, event, helper) {
	const Http = new XMLHttpRequest();
    let url = 'https://apps.tdcx.com.my/SalesforceTest/api/values/301/10001-User@1234-2ndAt-2023-02-10-15-55-00'
    console.log(url);      
    Http.open("GET", url);
    Http.send();
       
    },
    
    test: function(cmp, evt) {
	const xhr = new XMLHttpRequest();
	xhr.open('GET', 'https://apps.tdcx.com.my/SalesforceTest/api/values/99', true);



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
            
		 if(final.includes("CLOSER")&& i != 1){
        const myFinalArray = final.split(","); 
        var option = document.createElement("option");
        option.text = myFinalArray[0]+" | "+myFinalArray[7];
        option.value = myFinalArray[0];
        var select = document.getElementById("Pause_Codes");
        select.appendChild(option);
        console.log(final);
         }
            else{
                
            }
            }
        


        


	};

	xhr.send(null);


	 },
    
    
    
 onCheck: function(cmp, evt) {
		 var checkCmp = cmp.find("checkbox");
		 var resultCmp = cmp.find("checkResult");
		 resultCmp.set("v.value", ""+checkCmp.get("v.value"));
		console.log(checkCmp.get("v.value"));

	 },
     selectWelcome: function(cmp, evt) {
            cmp.set('v.Start','yes');
            var e = document.getElementById("Pause_Codes");
            var value = e.value;
			cmp.set('v.State',value);

	 },
          selectDrop: function(cmp, evt) {

			
			cmp.getEvent('renderPanel').setParams({
                    type: 'c:LoadingPage',
            			attributes : { 
                            presence : "Available",
                          userCred : "10001-User@1234"}
                }).fire();

	 },
              backButton: function(cmp, evt) {
            cmp.set('v.Start','no');

	 },
    
    
        // Test
    testButton: function(cmp, event, helper) {
		
        try{

const xhr = new XMLHttpRequest();
             let inputValue = document.getElementById("VD_login").value; 
             let inputValue2 = document.getElementById("VD_pass").value;
             let finalValue = inputValue +"-"+inputValue2;
            let url = "https://apps.tdcx.com.my/SalesforceTest/api/values/1/"+finalValue;
xhr.open('GET', url, true);
            
			console.log(inputValue);
            console.log(inputValue2);
            console.log(finalValue);


xhr.onload = () => {


      console.log(xhr.response);
      console.log(xhr.responseText);
    
    if(xhr.responseText.includes("callerid")){
          console.log(" LOGGED IN DETECTED");
                cmp.getEvent('renderPanel').setParams({
                    type: 'c:ctiLoginPanel',
                    attributes : {
                            State : 'Salesforce',
                        switchText: 'Switch to Vicidial',
                        Start :'yes',
    						
                        }
                }).fire();
    
}
else {


console.log("CURRENT STATE NOT LOGGED IN")
cmp.getEvent('renderPanel').setParams({
                    type: 'c:ctiLoginPanel',
                    attributes : {
                            State : 'Vicidial',
   							 Likedisable : false,
                        	switchText: 'Switch to Salesforce',
                        	Start :'yes',
                        }
                }).fire();

    		
}

};

xhr.send(null);

}

catch (ex) {
console.log('Exception: '+ex);
}



               								

        
        
    },
        
        
        init: function(cmp, event, helper) {



    },
        NewContact : function( cmp, event, helper) {
		 helper.NewContacts(cmp, event, helper);
},
    
    
        getUtilityInfo : function(component, event, helper) {
            
            
            
         	/*var utilityBarAPI = component.find("utilitybar");
      		var test=  utilityBarAPI.getAllUtilityInfo();
            console.log(test);
            var myUtilityInfo = test[0];
            console.log(myUtilityInfo.id);
            var result = myUtilityInfo.id;
            
                    sforce.opencti.saveLog({
          value : {
            entityApiName : 'Call',
            WhoId : cmp.get('v.recordId'),
            Description : 'Outbound Call made by agent',
            Subject : 'Outbound Call',
            Priority : 'Normal',
            Status : 'Completed',
            Type : 'Call',

            
          },callback : function(response) {
if (response.success) {
console.log('API method call executed successfully! returnValue:', response.returnValue);
} else {
console.error('Something went wrong! Errors:', response.errors);
}
}
         
        });
            */

       
	

        
    },
        
})