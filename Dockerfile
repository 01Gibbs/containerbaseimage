# Onboarding Tracker container image (platform standard: see PLATFORM_STANDARDS.md).
# Multi-stage build: the jar is built inside the image, so no local build is needed first.
#   podman build -t onboarding-tracker:after .      (or docker build, if your tool provides the docker command)
#   podman run --rm -p 8080:8080 onboarding-tracker:after

# ---- Stage 1: build (JDK) ----
# Approved image, registry written in full, pinned to the Java 21 LTS line (never latest).
FROM docker.io/library/eclipse-temurin:21-jdk AS build
WORKDIR /src

# Gradle wrapper and build scripts first, so the dependency download is cached between source changes.
COPY gradlew settings.gradle build.gradle ./
COPY gradle ./gradle
RUN sh gradlew --no-daemon dependencies > /dev/null

COPY src ./src
RUN sh gradlew --no-daemon bootJar

# ---- Stage 2: runtime (JRE only) ----
FROM docker.io/library/eclipse-temurin:21-jre
WORKDIR /app

# Non-root system user that owns /app, including the H2 data folder (./data) the app writes to.
RUN groupadd --system --gid 10001 app \
 && useradd --system --uid 10001 --gid app --no-create-home --shell /usr/sbin/nologin app \
 && mkdir -p /app/data \
 && chown -R app:app /app

# Only the jar leaves the build stage: no source, Gradle caches or JDK in the final image.
COPY --from=build --chown=app:app /src/build/libs/onboarding-tracker-0.0.1-SNAPSHOT.jar app.jar

USER app

EXPOSE 8080
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "app.jar"]
