FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the fat jar directly
COPY build/libs/adservice.jar app.jar

EXPOSE 9555
ENTRYPOINT ["java", "-jar", "app.jar"] 
