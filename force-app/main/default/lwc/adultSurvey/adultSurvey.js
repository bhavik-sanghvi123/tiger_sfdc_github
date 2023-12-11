import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import SURVEYLINK_FIELD from '@salesforce/schema/Case.Survey_Link__c';

export default class AdultSurvey extends LightningElement {
    @api recordId;
    isLoading = false;
    showSurvey = false;
    
    @wire(getRecord, { recordId: '$recordId', fields: [SURVEYLINK_FIELD] })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'No survey link';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading survey',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.showSurvey = true;
            this.case = data;
        }
    }

    get surveyLink() {
        return getFieldValue(this.case, SURVEYLINK_FIELD);
    }

}