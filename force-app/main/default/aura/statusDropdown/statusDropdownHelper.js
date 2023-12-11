/*
Copyright 2016 salesforce.com, inc. All rights reserved.

Use of this software is subject to the salesforce.com Developerforce Terms of Use and other applicable terms that salesforce.com may make available, as may be amended from time to time. You may not decompile, reverse engineer, disassemble, attempt to derive the source code of, decrypt, modify, or create derivative works of this software, updates thereto, or any part thereof. You may not use the software to engage in any development activity that infringes the rights of a third party, including that which interferes with, damages, or accesses in an unauthorized manner the servers, networks, or other properties or services of salesforce.com or any third party.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL SALESFORCE.COM HAVE ANY LIABILITY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES, OR DAMAGES BASED ON LOST PROFITS, DATA OR USE, IN CONNECTION WITH THE SOFTWARE, HOWEVER CAUSED AND, WHETHER IN CONTRACT, TORT OR UNDER ANY OTHER THEORY OF LIABILITY, WHETHER OR NOT YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*/

({
    // expand the status dropdown on click
    toggleStatus: function(cmp) {
        var dropdown = cmp.find('dropdownContainer');
        $A.util.toggleClass(dropdown, 'slds-is-open');
    },

    // update the status dropdown (presence and icon)
    setStatusName: function(cmp, selectOption) {
        var newStatus = selectOption.getAttribute('data-value-name');
        var iconType = selectOption.getAttribute('data-value-iconType');
        cmp.set('v.presence', newStatus);
        this.renderIcon(cmp, iconType);
    },

    // update the status icon on the first row of the status dropdown
    renderIcon : function(cmp, iconType) {
        $A.createComponent("c:svg",
            {"class": 'slds-icon slds-icon--x-small slds-icon-text-'+iconType,
            "aura:id": "statusIcon",
            "xlinkHref": "/resource/slds/assets/icons/utility-sprite/svg/symbols.svg#record"},
            function(newIcon) {
                if (cmp.isValid()) {
                    cmp.set('v.icon', [ newIcon ]);
                }
            });
    },

    // on logout, disable click to dial and bring up the cti login panel
    handleLogout: function(cmp) {

    },

    // set the panel label by firing the editPanel event
    setLabel: function (cmp, label) {
        cmp.getEvent('editPanel').setParams({
                label: label
        }).fire();
    },

    // notify the phone panel that the presence has changed
    notifyPhonePanel: function(cmp, helper, newStatus) {
 
        cmp.getEvent('onlinePresenceChanged').setParams({
            newStatus: newStatus
        }).fire();

    },
        matchingNumbers : function(number1, number2){
        var target = number2.replace(/\D/g,'')
        return number1.replace(/\D/g,'') == target && target.length > 0;
    },
    
        search : function(cmp, number, onCompletion) {
        var args = {
            apexClass : 'SoftphoneContactSearchController',
            methodName : 'getContacts',
            methodParams : 'name=' + number,
            callback : function(result) {
                if (result.success) {
                    var searchResults = JSON.parse(result.returnValue.runApex);
                    onCompletion && onCompletion(cmp, searchResults[0]);
                } else {
                    throw new Error(
                            'Unable to perform a search using Open CTI. Contact your admin.');
                }
            }
        };
        sforce.opencti.runApex(args);
    },
    
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
        cmp.set('v.searchResults', []);
        console.log(record.Account);
    },
    //CUSTOMIZED HELPER START HERE
        changeStatusVicidial: function (cmp, event, helper,result) {
            console.log("result :");   
			console.log(result);
            
            
            if (result=="Available"){
                const xhr = new XMLHttpRequest();
                    xhr.open('GET', 'https://apps.tdcx.com.my/SalesforceTest/api/values/3', true);
                    
                    
                    
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
                    xhr.open('GET', 'https://apps.tdcx.com.my/SalesforceTest/api/values/2', true);
                    
                    
                    
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
                                     
          },
              
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //EXTRA FUNCTION START HERE 
    getTimeSheet : function(cmp, event, helper,result,onCompletion) {
        if (result == "Available"){
            try{

const xhr = new XMLHttpRequest();
xhr.open('GET', 'https://apps.tdcx.com.my/SalesforceTest/api/values/1', true);



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
	var inputValue = "601127328636";
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
                    }
                    onCompletion && onCompletion(cmp, inputValue);
        				//callPhone START HERE
					        var attributes = {
                            'state' : 'Inbound',
                            'recordName' : inputValue
                        };
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
                        console.log(record.Id);
                		   sforce.opencti.screenPop({
                                        type : sforce.opencti.SCREENPOP_TYPE.SOBJECT,
                                        params : { recordId : record.Id },
                                    });
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
}
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////

    
})