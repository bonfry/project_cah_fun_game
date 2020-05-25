FROM google/dart as dartbuild

WORKDIR  /usr/src/app
RUN mkdir cah_backend && mkdir lib_common
COPY lib_webserver cah_backend
COPY lib_common lib_common

WORKDIR  /usr/src/app/cah_backend
RUN pub get
RUN pub get --offline && dart2native bin/main.dart -o ./dweb

FROM ubuntu:latest
WORKDIR  /usr/src/app
COPY --from=dartbuild /usr/src/app/cah_backend/dweb .
RUN mkdir card_datasource
COPY card_datasource card_datasource
RUN ls

CMD ["./dweb"]