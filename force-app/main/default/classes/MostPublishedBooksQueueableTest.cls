/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@IsTest
public class MostPublishedBooksQueueableTest {
    @IsTest
    static void testSuccessfulExecution() {
        // Create test data
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('[{"Publisher":"Test Publisher","Books":[' +
            '{"Title":"Book1","Author":"Author1","Edition":700000},' +
            '{"Title":"Book2","Author":"Author2","Edition":500000},' +
            '{"Title":"Book3","Author":"Author3","Edition":800000}' +
            ']}]');
        mockResponse.setStatusCode(200);
        
        // Set up the mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        Test.startTest();
        
        // Enqueue the job
        System.enqueueJob(new MostPublishedBooksQueueable());
        
        // Process events
        Test.getEventBus().deliver();
        
        Test.stopTest();
        
        // Verify that the job was executed
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors 
            FROM AsyncApexJob 
            WHERE JobType = 'Queueable' 
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];
        
        System.assertEquals('Completed', job.Status, 'Job should complete successfully');
        System.assertEquals(0, job.NumberOfErrors, 'Job should complete without errors');
    }
    
    @IsTest
    static void testNoQualifyingBooks() {
        // Create test data with no books over 600000 edition
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('[{"Publisher":"Test Publisher","Books":[' +
            '{"Title":"Book1","Author":"Author1","Edition":500000},' +
            '{"Title":"Book2","Author":"Author2","Edition":400000}' +
            ']}]');
        mockResponse.setStatusCode(200);
        
        // Set up the mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        Test.startTest();
        
        System.enqueueJob(new MostPublishedBooksQueueable());
        Test.getEventBus().deliver();
        
        Test.stopTest();
        
        // Verify job completion
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors 
            FROM AsyncApexJob 
            WHERE JobType = 'Queueable' 
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];
        
        System.assertEquals('Completed', job.Status, 'Job should complete successfully');
        System.assertEquals(0, job.NumberOfErrors, 'Job should complete without errors');
    }
    
    @IsTest
    static void testHttpError() {
        // Create error response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(500);
        mockResponse.setBody('Error');
        
        // Set up the mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        Test.startTest();
        
        System.enqueueJob(new MostPublishedBooksQueueable());
        Test.getEventBus().deliver();
        
        Test.stopTest();
        
        // Verify job completion despite error
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors 
            FROM AsyncApexJob 
            WHERE JobType = 'Queueable' 
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];
        
        System.assertEquals('Completed', job.Status, 'Job should complete even with HTTP error');
        System.assertEquals(0, job.NumberOfErrors, 'Job should handle errors gracefully');
    }
    
    // Mock HTTP Response Generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;
        
        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }
        
        public HttpResponse respond(HttpRequest request) {
            return response;
        }
    }
}