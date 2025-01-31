
// Clear the current schedules
for(CronTrigger ct : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE 'MostPublishedBooks%']) {
    System.abortJob(ct.Id);
 }
 


// Create a new instance of the scheduler
MostPublishedBooksScheduler scheduler = new MostPublishedBooksScheduler();

// Schedule 12 different jobs at specific minute intervals
System.schedule('MostPublishedBooks_05', '0 5 * * * ?', scheduler);
System.schedule('MostPublishedBooks_10', '0 10 * * * ?', scheduler);
System.schedule('MostPublishedBooks_15', '0 15 * * * ?', scheduler);
System.schedule('MostPublishedBooks_20', '0 20 * * * ?', scheduler);
System.schedule('MostPublishedBooks_25', '0 25 * * * ?', scheduler);
System.schedule('MostPublishedBooks_30', '0 30 * * * ?', scheduler);
System.schedule('MostPublishedBooks_35', '0 35 * * * ?', scheduler);
System.schedule('MostPublishedBooks_40', '0 40 * * * ?', scheduler);
System.schedule('MostPublishedBooks_45', '0 45 * * * ?', scheduler);
System.schedule('MostPublishedBooks_50', '0 50 * * * ?', scheduler);
System.schedule('MostPublishedBooks_55', '0 55 * * * ?', scheduler);
System.schedule('MostPublishedBooks_00', '0 0 * * * ?', scheduler);

// Retrieve and log the scheduled jobs for verification
List<CronTrigger> scheduledJobs = [SELECT Id, CronExpression, CronJobDetail.Name 
                                  FROM CronTrigger 
                                  WHERE CronJobDetail.Name LIKE 'MostPublishedBooks%'];

System.debug('Number of scheduled jobs: ' + scheduledJobs.size());
for (CronTrigger ct : scheduledJobs) {
    System.debug('Job Name: ' + ct.CronJobDetail.Name + ', Cron Expression: ' + ct.CronExpression);
}
