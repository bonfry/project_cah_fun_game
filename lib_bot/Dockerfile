FROM google/dart as dartbuild

WORKDIR /usr/src/app
RUN  mkdir cah_bot && mkdir lib_common && mkdir lib_webserver
COPY lib_bot cah_bot
COPY lib_common lib_common
COPY lib_webserver lib_webserver

WORKDIR /usr/src/app/cah_bot
RUN pub get && pub get --offline
RUN dart2native bin/main.dart -o ./bot

FROM ubuntu:latest
WORKDIR /usr/src/app
COPY --from=dartbuild /usr/src/app/cah_bot/bot .
RUN mkdir card_datasource
COPY card_datasource card_datasource

CMD ["./bot"]