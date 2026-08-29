# ---- Stage 1: build the WAR with Maven ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build
COPY pom.xml .
# Cache dependencies separately from source for faster rebuilds
RUN mvn -B dependency:go-offline || true
COPY src ./src
RUN mvn -B clean package

# ---- Stage 2: run it on Tomcat 10.1 (Jakarta / Servlet 6.0) ----
FROM tomcat:10.1-jdk17-temurin
# Remove default apps and deploy ours as ROOT so it serves at "/"
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /build/target/SkillExchangeProject.war /usr/local/tomcat/webapps/ROOT.war

# DB connection is read from environment variables at runtime by the app
# (DatabaseInfo.java) — DB_URL, DB_USER, DB_PASSWORD. Intentionally NOT
# set here with ENV: baking even placeholder credentials into an image
# layer is bad practice (they'd sit in the image history forever, and
# scanners flag it). Pass real values at "docker run -e ..." time or via
# docker-compose.yml / your orchestrator's secret injection. If unset,
# the app falls back to a local dev default (localhost/root/password).

EXPOSE 8080
CMD ["catalina.sh", "run"]
