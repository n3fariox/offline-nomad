FROM ${DOCKER_HUB}python:3.7

ARG USER=vscode
ARG GROUP=vscode
ARG UID=1000
ARG GID=1000
ARG PW=VSCODE
ARG COMMIT

ENV DUSER=$USER
ENV DGROUP=$GROUP
ENV DUID=$UID
ENV DGID=$GID
ENV DPW=$PW
ENV COMMIT=$COMMIT
ENV EXTENSION_PATH=/home/${DUSER}/.vscode-server/extensions
ENV PATH=${PATH}:/home/$DUSER/.local/bin

RUN groupadd -f --gid=${DGID} ${DGROUP} \
 && groupadd -f --gid=${DUID} ${DUSER} \
 && useradd -l -m ${DUSER} --uid=${DUID} --gid=${DUID} -G ${DGROUP} \
 && usermod -a -G sudo ${DUSER} \
 && echo "${DUSER}:${DPW}" | chpasswd \
 && pip install -U pip

USER ${DUSER}

COPY --chown=${DUID}:${DGID} vscode-server-linux-x64*${COMMIT}*.tar.gz /tmp/

VOLUME "/extensions"

RUN mkdir -p /home/${DUSER}/.vscode-server/bin/${COMMIT} \
 && tar -xvf /tmp/vscode-server-linux-x64*${COMMIT}*.tar.gz --strip-components 1 \
    -C /home/${DUSER}/.vscode-server/bin/${COMMIT} \
 && rm /tmp/vscode-server-linux-x64*${COMMIT}*.tar.gz \
 && chown -R ${DUID}:${DGID} /home/${DUSER}/.vscode-server/ \
 && ln -s /extensions ${EXTENSION_PATH}
