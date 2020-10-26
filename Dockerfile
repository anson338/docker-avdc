FROM inn0kenty/pyinstaller-alpine:3.8 as build

# 软件包版本号
ARG AVDC_VERSION
WORKDIR /build

RUN \
    wget -O - https://github.com/yoshiko2/AV_Data_Capture/archive/${AVDC_VERSION}.tar.gz | tar xz && \
    mv AV_Data_Capture-${AVDC_VERSION} src && cd src && \
    sed -i '/pyinstaller/d' requirements.txt && \
    pip install -r requirements.txt && \
    cloudscraper_path=$(python -c 'import cloudscraper as _; print(_.__path__[0])' | tail -n 1) && \
    pyinstaller \
        --noconfirm --clean --onefile --name app AV_Data_Capture.py \
        --hidden-import ADC_function.py \
        --hidden-import core.py \
        --add-data "$cloudscraper_path:cloudscraper"

FROM alpine
LABEL maintainer="VergilGao"

# 镜像版本号
ARG BUILD_DATE
ARG VERSION
LABEL build_version="catfight360.com version:- ${VERSION} build-date:- ${BUILD_DATE}"

WORKDIR /app

COPY --from=build /build/src/dist/app .

COPY docker-entrypoint.sh docker-entrypoint.sh

VOLUME /app/data

RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
