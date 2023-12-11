/*
Copyright 2016 salesforce.com, inc. All rights reserved.

Use of this software is subject to the salesforce.com Developerforce Terms of Use and other applicable terms that salesforce.com may make available, as may be amended from time to time. You may not decompile, reverse engineer, disassemble, attempt to derive the source code of, decrypt, modify, or create derivative works of this software, updates thereto, or any part thereof. You may not use the software to engage in any development activity that infringes the rights of a third party, including that which interferes with, damages, or accesses in an unauthorized manner the servers, networks, or other properties or services of salesforce.com or any third party.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL SALESFORCE.COM HAVE ANY LIABILITY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES, OR DAMAGES BASED ON LOST PROFITS, DATA OR USE, IN CONNECTION WITH THE SOFTWARE, HOWEVER CAUSED AND, WHETHER IN CONTRACT, TORT OR UNDER ANY OTHER THEORY OF LIABILITY, WHETHER OR NOT YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*/

global class SoftphoneContactSearchController {
    webService static String getContacts(String name) {
        String userid=UserInfo.getUserId();
        List<Contact> contactList = new List<Contact>();
        for (Contact contact: [SELECT Id, Phone, Name, Account.Name FROM Contact WHERE (phone = :name ) AND (Type__c = 'Adult') LIMIT 10]){
            contactList.add(contact);
        }
        return JSON.serialize(contactList);
    }
    webService static String getOwnerID(String name) {
        String userid=UserInfo.getUserId();
        return userid;
    }
    webService static String getUserContacts(String name) {
        String userid=UserInfo.getUserId();
        List<Contact> contactList = new List<Contact>();
        for (Contact contact: [SELECT Id, Phone, Name, Account.Name FROM Contact WHERE (Phone = :name )]){
            contactList.add(contact);
        }
        return JSON.serialize(contactList);
    }
        webService static String getCustomerCase(String name) {
        List<Case> contactList = new List<Case>();
        for (Case contact: [SELECT Id,Account.Name,Status,Subject, CaseNumber,AccountId,Owner.Name FROM Case WHERE Contact.Phone = :name AND Status != 'Completed']){
            contactList.add(contact);
        }
        return JSON.serialize(contactList);
    }
        webService static String getRecordTypeID(String name) {
        List<RecordType> contactList = new List<RecordType>();
        for (RecordType contact: [SELECT Id,Name FROM RecordType WHERE Name IN ('Uncontactable Reason','Unsuccessful Reason','Successful Reason','Invalid Reason')]){
            contactList.add(contact);
        }
        return JSON.serialize(contactList);
    }
        webService static String getReason(String name) {
        List<Affiliate_Value__c> contactList = new List<Affiliate_Value__c>();
        for (Affiliate_Value__c contact: [SELECT Id,Name,RecordType.Name FROM Affiliate_Value__c WHERE RecordType.Name = :name]){
            contactList.add(contact);
        }
        return JSON.serialize(contactList);
    }
}