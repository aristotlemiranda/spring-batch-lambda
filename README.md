# spring-batch-lambda
Spring Batch On Lambda with Sample Usage of SAM and Local Docker Run


#Lambda Local Testing Using Docker
# Build and run
mvn clean package -DskipTests
docker build -t batch-lambda-demo .
docker run -d -p 9000:8080 batch-lambda-demo

# Test with curl
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"key1":"value1","key2":"value2"}'




#Lambda Local Testing using SAM

# Direct function invocation
sam local invoke BatchLambdaDemo -e event.json

# Start local API Gateway (if you added the API event)
sam local start-api

# Test via HTTP
curl -X POST http://localhost:3000/batch -d '{"key1":"value1"}'



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
