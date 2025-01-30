@isTest
public class MostPublishedBooksSchedulerTest {
    public static final String CRON_EXP = '0 0 0 * * ?';

    @isTest
    static void testExecute() {
        // Set up mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('[{"Publisher":"Test Publisher","Books":[{"Title":"Test Book 1","Author":"Author 1","Edition":700000},{"Title":"Test Book 2","Author":"Author 2","Edition":800000}]}]');
        mockResponse.setStatusCode(200);
        
        // Create a mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        // Schedule the job
        Test.startTest();
        String jobId = System.schedule('Test Job', CRON_EXP, new MostPublishedBooksScheduler());
        Test.stopTest();

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        // Verify the expressions are the same
        Assert.areEqual(CRON_EXP, ct.CronExpression);

        // Verify the job has not run yet
        Assert.areEqual(0, ct.TimesTriggered);
        
        // Verify the next scheduled run time
        Assert.areNotEqual(null, ct.NextFireTime);

        // Simulate event delivery
        Test.getEventBus().deliver();
    }

    @isTest
    static void testFetchAndPublishBooks() {
        // Set up mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('[{"Publisher":"Test Publisher","Books":[{"Title":"Test Book 1","Author":"Author 1","Edition":700000},{"Title":"Test Book 2","Author":"Author 2","Edition":800000}]}]');
        mockResponse.setStatusCode(200);
        
        // Create a mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        // Execute the method directly
        Test.startTest();
        MostPublishedBooksScheduler scheduler = new MostPublishedBooksScheduler();
        scheduler.fetchAndPublishBooks();
        Test.stopTest();
        
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;
        
        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }
        
        public HttpResponse respond(HttpRequest req) {
            return response;
        }
    }
}