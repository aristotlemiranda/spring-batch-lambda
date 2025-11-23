FROM amazonlinux:2023

# Install Amazon Corretto 21 (full JDK with jar command)
RUN yum update -y && \
    yum install -y java-21-amazon-corretto-devel && \
    yum clean all

# Install AWS Lambda Runtime Interface Client
RUN yum install -y curl --allowerasing && \
    curl -Lo /usr/local/bin/aws-lambda-rie https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie && \
    chmod +x /usr/local/bin/aws-lambda-rie

# Set environment variables
ENV LAMBDA_TASK_ROOT=/var/task
ENV LAMBDA_RUNTIME_DIR=/var/runtime
ENV JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto
ENV PATH=$PATH:$JAVA_HOME/bin

# Create task directory
RUN mkdir -p ${LAMBDA_TASK_ROOT}

# Copy and extract the JAR file
COPY target/batch-lambda-demo-0.0.1-SNAPSHOT.jar /tmp/app.jar
RUN cd ${LAMBDA_TASK_ROOT} && jar -xf /tmp/app.jar && rm /tmp/app.jar

# Set working directory
WORKDIR ${LAMBDA_TASK_ROOT}

# Entry point
ENTRYPOINT ["/usr/local/bin/aws-lambda-rie"]
CMD ["java", "-cp", ".", "com.amazonaws.services.lambda.runtime.api.client.AWSLambda", "com.example.batch_lambda_demo.BatchLambdaHandler::handleRequest"]