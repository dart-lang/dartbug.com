# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM dart:2.12 AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* .
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o /server

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /server /bin/

# Start server.
EXPOSE 8080
CMD ["/bin/server"]
