# Onboarding Tracker container image.
# Build the jar first on your machine:   gradlew.bat bootJar
# Then build the image:                  podman build -t onboarding-tracker:before .
#                                        (or docker build, if your tool provides the docker command)

FROM docker.io/library/openjdk:17-jdk-slim

WORKDIR /app
COPY build/libs/onboarding-tracker-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
