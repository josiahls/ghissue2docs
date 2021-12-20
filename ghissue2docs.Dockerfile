FROM continuumio/miniconda3
# FROM pytorch/pytorch

ARG BUILD=dev

ENV LIBRARY_NAME ghissue2docs
ENV CONTAINER_USER "${LIBRARY_NAME}_user"
ENV CONTAINER_GROUP "${LIBRARY_NAME}_group"
ENV CONTAINER_UID 1000
# Add user to conda
RUN addgroup --gid $CONTAINER_UID $CONTAINER_GROUP && \
    adduser --uid $CONTAINER_UID --gid $CONTAINER_UID $CONTAINER_USER --disabled-password  && \
    mkdir -p /opt/conda && chown $CONTAINER_USER /opt/conda

RUN apt-get update && apt-get install -y software-properties-common rsync curl gnupg
#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0 && apt-add-repository https://cli.github.com/packages
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
RUN apt-get update && apt-get install -y git libglib2.0-dev libxext6 libsm6 nano gh && apt-get update

RUN pip install fastcore watchdog[watchmedo] jupyterlab

WORKDIR /home/$CONTAINER_USER

RUN chown $CONTAINER_USER:$CONTAINER_GROUP -R /opt/conda/bin
#RUN chown $CONTAINER_USER:$CONTAINER_GROUP -R /opt/conda/lib/python3.*/site-packages
RUN chown $CONTAINER_USER:$CONTAINER_GROUP -R /home/$CONTAINER_USER

COPY --chown=$CONTAINER_USER:$CONTAINER_GROUP extra/themes.jupyterlab-settings /home/$CONTAINER_USER/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/
COPY --chown=$CONTAINER_USER:$CONTAINER_GROUP extra/shortcuts.jupyterlab-settings /home/$CONTAINER_USER/.jupyter/lab/user-settings/@jupyterlab/shortcuts-extension/
COPY --chown=$CONTAINER_USER:$CONTAINER_GROUP extra/tracker.jupyterlab-settings /home/$CONTAINER_USER/.jupyter/lab/user-settings/@jupyterlab/notebook-extension/

USER $CONTAINER_USER
WORKDIR /home/$CONTAINER_USER
ENV PATH="/home/$CONTAINER_USER/.local/bin:${PATH}"

COPY --chown=$CONTAINER_USER:$CONTAINER_GROUP . ${LIBRARY_NAME}
RUN /bin/bash -c "if [[ $BUILD == 'prod' ]] ; then echo \"Production Build\" && cd ${LIBRARY_NAME} && pip install . ; fi"
RUN /bin/bash -c "if [[ $BUILD == 'dev' ]] ; then echo \"Development Build\" && cd ${LIBRARY_NAME} && pip install -e \".[dev]\" --user ; fi"

RUN echo '#!/bin/bash\npip install -e .[dev]  && jupyter lab --ip=0.0.0.0 --port=8080 --allow-root --no-browser  --NotebookApp.token='' --NotebookApp.password=''' >> run_jupyter.sh

RUN /bin/bash -c "cd ${LIBRARY_NAME} && pip install -e ."
RUN chmod u+x run_jupyter.sh