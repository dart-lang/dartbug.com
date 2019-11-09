# Insired by https://itnext.io/experiments-with-dart-microservices-fa117aa408c7
FROM google/dart AS dart-runtime

WORKDIR /app

ADD pubspec.* /app/
RUN pub get
ADD bin /app/bin/
ADD lib /app/lib/
RUN pub get --offline
RUN dart2native /app/bin/server.dart -o /app/server

FROM frolvlad/alpine-glibc:glibc-2.30

COPY --from=dart-runtime /app/server /server

CMD []
ENTRYPOINT ["/server"]

EXPOSE 8080
