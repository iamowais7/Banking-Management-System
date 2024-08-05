import { LightningElement, api, track, wire } from 'lwc';
import getTransactionDetails from '@salesforce/apex/statementController.getTransactionDetails';
//import generateMail from '@salesforce/apex/GeneratePDFMail.generateMail';


export default class Statement extends LightningElement {


    value;
    @track tableView = false;
    @track startDate;
    @track endDate;
    @api recordId;
    @track data;
    @track items;
    @track startingRecord = 1;
    @track page = 1;
    @track endingRecord = 0;
    @track totalRecordCount;
    @track totalPage;
    @track pageSize = 5;


    @track columns = [
        { label: 'ID', fieldName: 'Id', type: 'text' },
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Amount', fieldName: 'Amount__c', type: 'currency' },
        { label: 'Status', fieldName: 'Status__c', type: 'text' },
        { label: 'Type', fieldName: 'Type__c', type: 'text' }
    ];


    @wire(getTransactionDetails) transactionRecords({ error, data }) {


        if (data) {
            this.data = data;
        } else if (error) {
            this.data = undefined;
        }
    }


    startDateChange(event) {
        this.startDate = event.detail.value;
    }
    endDateChange(event) {
        this.endDate = event.detail.value;
    }


    handleClick(event) {


        this.tableView = true;
        this.value = event.detail.value;
        getTransactionDetails({
            recordKey: this.recordId,
            startDate: this.startDate,
            endDate: this.endDate
        })
            .then(result => {
                this.items = result;
                this.totalRecordCount = result.length;
                this.totalPage = Math.ceil(this.totalRecordCount / this.pageSize);
                this.data = this.items.slice(0, this.pageSize);
                this.endingRecord = this.pageSize;
            })
    }




    handlePrevious(event) {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.displayRecordPerPage(this.page);
        }
    }


    handleNext(event) {
        if (this.page < this.totalPage && this.page !== this.totalPage) {
            this.page = this.page + 1;
            this.displayRecordPerPage(this.page);
        }
    }


    displayRecordPerPage(page) {
        this.startingRecord = (page - 1) * this.pageSize;
        this.endingRecord = page * this.pageSize;
        this.endingRecord = (this.endingRecord > this.totalRecordCount) ? this.totalRecordCount : this.endingRecord;
        this.data = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }


    downloadCSVFile() {
        let rowEnd = '\n';
        let csvString = '';


        let rowData = new Set();


        this.data.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });
        rowData = Array.from(rowData);


        csvString += rowData.join(',');
        csvString += rowEnd;


        for (let i = 0; i < this.data.length; i++) {
            let colValue = 0;




            for (let key in rowData) {
                if (rowData.hasOwnProperty(key)) {


                    let rowKey = rowData[key];


                    if (colValue > 0) {
                        csvString += ',';
                    }


                    let value = this.data[i][rowKey] === undefined ? '' : this.data[i][rowKey];
                    csvString += '"' + value + '"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }


        let downloadElement = document.createElement('a');


        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';


        downloadElement.download = 'Transaction Data.csv';


        document.body.appendChild(downloadElement);


        downloadElement.click();
    }


    // downloadPDFFile() {


    //     let cmpltUrl = window.location.href;
    //     let reqUrl = cmpltUrl.substring(0, cmpltUrl.indexOf(".com/"));
    //     reqUrl = reqUrl.concat('.com/apex/GeneratePdf?id=' + this.recordId + '&fromDate=' + this.startDate + '&toDate=' + this.endDate);
    //     window.open(reqUrl);
    // }


    mailPDFFile() {


        generateMail({ stDate: this.startDate, eddate: this.endDate, recId: this.recordId });
    }
}

