import { LightningElement, track } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class MostPublishedBooks extends LightningElement {
    @track books = [];
    subscription = null;
    channelName = '/event/MostPublishedBook__e';
    
    columns = [
        { label: '📖 Title', fieldName: 'Title', type: 'text' },
        { label: '👨‍💼 Author', fieldName: 'Author', type: 'text' },
        { label: '🏢 Publisher', fieldName: 'Publisher', type: 'text' },
        { label: '🔢 Edition Size', fieldName: 'formattedEdition', type: 'text' }
    ];

    connectedCallback() {
        this.handleSubscribe();
        this.registerErrorListener();
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }

    handleSubscribe() {
        const messageCallback = (response) => {
            console.log('Received event:', response);
            try {
                const books = JSON.parse(response.data.payload.Books__c);
                this.books = books.map(book => ({
                    ...book,
                    formattedEdition: new Intl.NumberFormat().format(book.Edition)
                }));
                console.log('Processed books:', this.books);
            } catch (error) {
                console.error('Error processing event data:', error);
            }
        };

        subscribe(this.channelName, -1, messageCallback)
            .then(response => {
                this.subscription = response;
            });
    }

    handleUnsubscribe() {
        if (this.subscription) {
            unsubscribe(this.subscription);
        }
    }

    registerErrorListener() {
        onError(error => {
            console.error('EMP API error:', error);
        });
    }
}