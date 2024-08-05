import { LightningElement, track, wire, api } from 'lwc';
import getTransactionDetails from '@salesforce/apex/miniStatementController.getTransactionDetails';


export default class miniStatementComponent extends LightningElement {


    @track tableView = false;
    @api recordId;
    @track data;
    @track columns = [
        { label: 'Name', fieldName: 'nameUrl', type: 'url', typeAttributes: { label: { fieldName: 'name' }, target: '_blank' }, sortable: true },
        { label: 'Amount', fieldName: 'amount', type: 'currency', sortable: true },
        { label: 'Type', fieldName: 'type', type: 'text', sortable: true },
        { label: 'Status', fieldName: 'status', type: 'text', sortable: true }
    ];


    @wire(getTransactionDetails) transactionRecords({ error, data }) {


        if (data) {


            this.data = data;
        } else if (error) {
            this.data = undefined;
        }
    }


    value = 5;


    get options() {
        return [
            { label: '5', value: 5 },
            { label: '10', value: 10 },
            { label: '15', value: 15 },
            { label: '20', value: 20 },
        ];
    }


    handleChange(event) {


        this.tableView = true;
        this.value = event.detail.value;
        getTransactionDetails({
            recordKey: this.recordId,
            recordLimit: this.value
        })
            .then(result => {
                this.data = result;
            })
    }
}

