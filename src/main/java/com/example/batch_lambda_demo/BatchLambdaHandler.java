package com.example.batch_lambda_demo;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.context.ConfigurableApplicationContext;

public class BatchLambdaHandler implements RequestHandler<Object, String> {
    private static final ConfigurableApplicationContext ctx;

    static {
        SpringApplication app = new SpringApplication(BatchLambdaDemoApplication.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        ctx = app.run();
    }

    @Override
    public String handleRequest(Object input, Context context) {
        try {
            // Get Spring beans from context
            JobLauncher jobLauncher = ctx.getBean(JobLauncher.class);
            
            // Example: Get a specific job (you need to define this)
            // Job job = ctx.getBean("myBatchJob", Job.class);
            
            // Example: Get any service
            // MyService service = ctx.getBean(MyService.class);
            // String result = service.processData(input);
            
            // Run batch job
            // JobExecution execution = jobLauncher.run(job, new JobParameters());
            // return "Job completed: " + execution.getStatus();
            
            return "Handler executed successfully";
        } catch (Exception e) {
            throw new RuntimeException("Failed to execute: " + e.getMessage(), e);
        }
    }
}