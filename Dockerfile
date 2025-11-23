FROM public.ecr.aws/lambda/java:17

# Copy and extract the JAR file
COPY target/batch-lambda-demo-0.0.1-SNAPSHOT.jar /tmp/app.jar
RUN cd ${LAMBDA_TASK_ROOT} && jar -xf /tmp/app.jar && rm /tmp/app.jar

# Set the CMD to your handler
CMD ["com.example.batch_lambda_demo.BatchLambdaHandler::handleRequest"]