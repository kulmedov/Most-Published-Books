@isTest
public class MostPublishedBooksSchedulerTest {
    @testSetup
    static void setup() {
        // Prepare any test data if necessary
    }

    @isTest
    static void testSchedulerExecution() {
        Test.startTest();
        
        // Instantiate and execute the scheduler
        MostPublishedBooksScheduler scheduler = new MostPublishedBooksScheduler();
        scheduler.execute(null);
        
        Test.stopTest();

        // No direct assertions are needed since Salesforce handles scheduling
        // Just ensure no exceptions occurred
    }

    @isTest
    static void testQueueableExecution() {
        // Mock HTTP response to prevent real callouts
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();
        
        // Enqueue the Queueable job
        System.enqueueJob(new MostPublishedBooksQueueable());
        
        Test.stopTest();

        // Ensure that no exceptions occurred
    }

    // Mock HTTP response class for testing callouts
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('[{"Publisher": "Test Publisher", "Books": [{"Title": "Test Book", "Author": "Test Author", "Edition": 700000}]}]');
            return res;
        }
    }
}
