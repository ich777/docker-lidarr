#!/bin/bash
ARCH="x64"
if [ "$LIDARR_REL" == "latest" ]; then
    LAT_V="$(wget -qO- https://github.com/ich777/versions/raw/master/Lidarr | grep LATEST | cut -d '=' -f2)"
elif [ "$LIDARR_REL" == "nightly" ]; then
    LAT_V="$(wget -qO- https://github.com/ich777/versions/raw/master/Lidarr | grep NIGHTLY | cut -d '=' -f2)"
else
    echo "---Version manually set to: v$LIDARR_REL---"
    LAT_V="$LIDARR_REL"
fi

if [ ! -f ${DATA_DIR}/logs/Lidarr.txt ]; then
    CUR_V=""
else
    CUR_V="$(cat ${DATA_DIR}/logs/Lidarr.txt | grep " - Version" | tail -1 | rev | cut -d ' ' -f1 | rev)"
fi

if [ -z $LAT_V ]; then
    if [ -z $CUR_V ]; then
        echo "---Can't get latest version of Lidarr, putting container into sleep mode!---"
        sleep infinity
    else
        echo "---Can't get latest version of Lidarr, falling back to v$CUR_V---"
    fi
fi

echo "---Version Check---"
if [ "$LIDARR_REL" == "nightly" ]; then
    if [ -z "$CUR_V" ]; then
        echo "---Lidarr not found, downloading and installing v$LAT_V...---"
        cd ${DATA_DIR}
        if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/Lidarr-v$LAT_V.tar.gz "https://services.lidarr.audio/v1/update/nightly/updatefile?version=${LAT_V}&os=linux&runtime=netcore&arch=${ARCH}" ; then
            echo "---Successfully downloaded Lidarr v$LAT_V---"
        else
            echo "---Something went wrong, can't download Lidarr v$LAT_V, putting container into sleep mode!---"
            sleep infinity
        fi
        mkdir ${DATA_DIR}/Lidarr
        tar -C ${DATA_DIR}/Lidarr --strip-components=1 -xf ${DATA_DIR}/Lidarr-v$LAT_V.tar.gz
        rm ${DATA_DIR}/Lidarr-v$LAT_V.tar.gz
    elif [ "$CUR_V" != "$LAT_V" ]; then
        echo "---Version missmatch, installed v$CUR_V, downloading and installing latest v$LAT_V...---"
        cd ${DATA_DIR}
        if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/Lidarr-v$LAT_V.tar.gz "https://services.lidarr.audio/v1/update/nightly/updatefile?version=${LAT_V}&os=linux&runtime=netcore&arch=${ARCH}" ; then
            echo "---Successfully downloaded Lidarr v$LAT_V---"
        else
            echo "---Something went wrong, can't download Lidarr v$LAT_V, putting container into sleep mode!---"
            sleep infinity
        fi
        rm -R ${DATA_DIR}/Lidarr
        mkdir ${DATA_DIR}/Lidarr
        tar -C ${DATA_DIR}/Lidarr --strip-components=1 -xf ${DATA_DIR}/Lidarr-v$LAT_V.tar.gz
        rm ${DATA_DIR}/Lidarr-v$LAT_V.tar.gz
    elif [ "$CUR_V" == "$LAT_V" ]; then
        echo "---Lidarr v$CUR_V up-to-date---"
    fi
else
    if [ -z "$CUR_V" ]; then
        echo "---Lidarr not found, downloading and installing v$LAT_V...---"
        cd ${DATA_DIR}
        if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/Lidarr-v$LAT_V.tar.gz "https://github.com/lidarr/Lidarr/releases/download/v${LAT_V}/Lidarr.master.${LAT_V}.linux.tar.gz" ; then
            echo "---Successfully downloaded Lidarr v$LAT_V---"
        else
            echo "---Something went wrong, can't download Lidarr v$LAT_V, putting container into sleep mode!---"
            sleep infinity
        fi
        mkdir ${DATA_DIR}/Lidarr
        tar -C ${DATA_DIR}/Lidarr --strip-components=1 -xf ${DATA_DIR}/Lidarr-v$LAT_V.tar.gz
        rm ${DATA_DIR}/Lidarr-v$LAT_V.tar.gz
    elif [ "$CUR_V" != "$LAT_V" ]; then
        echo "---Version missmatch, installed v$CUR_V, downloading and installing latest v$LAT_V...---"
        cd ${DATA_DIR}
        if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/Lidarr-v$LAT_V.tar.gz "https://github.com/lidarr/Lidarr/releases/download/v${LAT_V}/Lidarr.master.${LAT_V}.linux.tar.gz" ; then
            echo "---Successfully downloaded Lidarr v$LAT_V---"
        else
            echo "---Something went wrong, can't download Lidarr v$LAT_V, putting container into sleep mode!---"
            sleep infinity
        fi
        rm -R ${DATA_DIR}/Lidarr
        mkdir ${DATA_DIR}/Lidarr
        tar -C ${DATA_DIR}/Lidarr --strip-components=1 -xf ${DATA_DIR}/Lidarr-v$LAT_V.tar.gz
        rm ${DATA_DIR}/Lidarr-v$LAT_V.tar.gz
    elif [ "$CUR_V" == "$LAT_V" ]; then
        echo "---Lidarr v$CUR_V up-to-date---"
    fi
fi

echo "---Preparing Server---"
if [ ! -f ${DATA_DIR}/config.xml ]; then
    echo "<Config>
  <LaunchBrowser>False</LaunchBrowser>
</Config>" > ${DATA_DIR}/config.xml
fi
if [ -f ${DATA_DIR}/lidarr.pid ]; then
    rm ${DATA_DIR}/lidarr.pid
fi
chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Starting Lidarr---"
cd ${DATA_DIR}
if [ "$LIDARR_REL" == "nightly" ]; then
    ${DATA_DIR}/Lidarr/Lidarr -nobrowser -data=${DATA_DIR} ${START_PARAMS}
else
    /usr/bin/mono ${MONO_START_PARAMS} ${DATA_DIR}/Lidarr/Lidarr.exe -nobrowser -data=${DATA_DIR} ${START_PARAMS}
fi