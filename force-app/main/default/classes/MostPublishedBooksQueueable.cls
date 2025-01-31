public class MostPublishedBooksQueueable implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext qc) {
        fetchAndPublishBooks();
    }
    
    private void fetchAndPublishBooks() {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://eoheai3ashoyzos.m.pipedream.net');
            request.setMethod('GET');
            
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                // Parse the publisher-books structure
                List<PublisherBooks> publisherBooksList = (List<PublisherBooks>)JSON.deserialize(
                    response.getBody(), 
                    List<PublisherBooks>.class
                );
                
                // Collect all books that meet the criteria
                List<Book> allFilteredBooks = new List<Book>();
                
                for(PublisherBooks pb : publisherBooksList) {
                    for(Book book : pb.Books) {
                        if(book.Edition > 600000) {
                            // Add publisher information to book
                            book.Publisher = pb.Publisher;
                            allFilteredBooks.add(book);
                        }
                    }
                }
                
                // Sort books by edition
                allFilteredBooks.sort();
                
                if(!allFilteredBooks.isEmpty()) {
                    // Publish platform event
                    MostPublishedBook__e event = new MostPublishedBook__e(
                        Books__c = JSON.serialize(allFilteredBooks)
                    );
                    Database.SaveResult result = EventBus.publish(event);
                    
                    System.debug('Published books: ' + allFilteredBooks);
                    System.debug('Event published: ' + result.isSuccess());
                }
            }
        } catch(Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
    
    public class PublisherBooks {
        public String Publisher;
        public List<Book> Books;
    }
    
    public class Book implements Comparable {
        public String Title;
        public String Author;
        public Integer Edition;
        public String Publisher;
        
        public Integer compareTo(Object compareTo) {
            Book other = (Book)compareTo;
            if (Edition > other.Edition) return -1;
            if (Edition < other.Edition) return 1;
            return 0;
        }
    }
}