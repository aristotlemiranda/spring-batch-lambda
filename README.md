# spring-batch-lambda
Spring Batch On Lambda with Sample Usage of SAM and Local Docker Run

## Project Structure

### Dockerfile
Custom Lambda container using Amazon Linux 2023 with Amazon Corretto JDK 21:
- **Base Image**: `amazonlinux:2023` for better control and security
- **JDK**: Amazon Corretto 21 (AWS's optimized OpenJDK distribution)
- **Security**: Runs as non-root user `netsbiz-lambda-runner`
- **Lambda Runtime**: AWS Lambda Runtime Interface Emulator for local testing
- **JAR Extraction**: Extracts Spring Boot fat JAR to `/var/task` for Lambda compatibility

#### Required Package Installations:
- **`java-21-amazon-corretto-devel`**: Full JDK with development tools (includes `jar` command for extracting JAR files)
- **`curl`**: Downloads AWS Lambda Runtime Interface Emulator from GitHub
- **`shadow-utils`**: Provides user management commands (`groupadd`, `useradd`) for creating non-root user
- **Why needed**: Amazon Linux 2023 base image is minimal and doesn't include these tools by default

### template.yaml
SAM (Serverless Application Model) template for AWS deployment:
- **Function Definition**: Defines `BatchLambdaDemo` Lambda function
- **Runtime**: Java 21 for better performance and faster cold starts
- **Handler**: Points to `BatchLambdaHandler::handleRequest` method
- **Resources**: 1024MB memory, 30s timeout
- **API Gateway**: Optional HTTP endpoint at `/batch` for REST API access

### event.json
Sample input event for testing Lambda function locally:
- **Purpose**: Simulates Lambda event payload
- **Format**: JSON object with key-value pairs
- **Usage**: Used by SAM CLI for local function invocation
- **Customizable**: Modify to test different input scenarios

## Lambda Local Testing Using Docker
```bash
# Build and run
mvn clean package -DskipTests
docker build -t batch-lambda-demo .
docker run -d -p 9000:8080 batch-lambda-demo

# Test with curl
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"key1":"value1","key2":"value2"}'
```

## Lambda Local Testing using SAM
```bash
# Direct function invocation
sam local invoke BatchLambdaDemo -e event.json

# Start local API Gateway (if you added the API event)
sam local start-api

# Test via HTTP
curl -X POST http://localhost:3000/batch -d '{"key1":"value1"}'
```



Problem Recap
Initial Issue: Spring Boot + AWS Lambda project couldn't run locally with SAM due to multiple build and packaging problems:
1. Maven Shade Plugin Configuration Error:
    * Error:  Cannot find 'resource' in class ManifestResourceTransformer
    * Cause: Incorrect transformer configuration syntax
2. JAR Structure Incompatibility:
    * Error:  ClassNotFoundException: com.example.batch_lambda_demo.BatchLambdaHandler
    * Cause: Spring Boot creates fat JARs with classes in  BOOT-INF/classes/, but Lambda expects classes at root level
3. Missing Database Dependency:
    * Error:  Failed to determine a suitable driver class
    * Cause: Spring Batch requires a database but none was configured
Resolution Steps
1. Fixed Maven Build Configuration
Before (broken):
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-shade-plugin</artifactId>
    <configuration>
        <transformers>
            <transformer implementation="...ManifestResourceTransformer">
                <manifestEntries>
                    <Main-Class>...</Main-Class>
                </manifestEntries>
            </transformer>
        </transformers>
    </configuration>
</plugin>

xml
After (working):
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-shade-plugin</artifactId>
    <version>3.4.1</version>
    <configuration>
        <createDependencyReducedPom>false</createDependencyReducedPom>
    </configuration>
</plugin>

xml
2. Added Missing Database Dependency
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>runtime</scope>
</dependency>

xml
3. Proper JAR Structure
* Before: Classes in  BOOT-INF/classes/com/example/...
* After: Classes at root level  com/example/...
* Solution: Maven Shade plugin creates Lambda-compatible flat JAR structure
Final Working Commands
# Build
mvn clean package -DskipTests

# Test locally
sam local invoke BatchLambdaDemo -e event.json

# Result: "Batch completed with exit code: 0"

bash
Key Insight: Spring Boot's default packaging isn't Lambda-compatible. Maven Shade plugin creates the correct flat JAR structure that AWS Lambda runtime can load.
