import { LightningElement, track, api } from 'lwc';

export default class RepeatOrder extends LightningElement {
    @api recordId;
    @api OrderId;
    @track frequencyValue;
    @track isRepeatOrder = true;

    flag = true;

    closeQuickAction() {
        if(this.flag) {
            const closeQA = new CustomEvent('close');
            // Dispatches the event.
            this.dispatchEvent(closeQA);
        }
    }

    // Makes sure user is only allowed to input numbers between 1-15
    handleFrequencyChange(event) {
        const numberValue = event.target.value;

        if(numberValue < 1 || numberValue > 15 || numberValue == '') {
            this.flag = false;
        }
        else {
            this.flag = true;
            this.frequencyValue = numberValue;
        }
    }
}