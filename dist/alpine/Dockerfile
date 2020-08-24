ARG BASE_IMAGE_HASH
ARG PY_VER

FROM datajoint/djbase:py${PY_VER}-alpine-${BASE_IMAGE_HASH} as jup_build
USER dja:anaconda

ENV APK_REQUIREMENTS /tmp/apk_requirements.txt
ENV PIP_REQUIREMENTS /tmp/pip_requirements.txt
COPY --chown=dja:anaconda ./dist/alpine/apk_requirements.txt \
    ./config/pip_requirements.txt /tmp/
COPY --chown=dja:anaconda ./utilities/djlab.py ./utilities/setup.py /src/
RUN \
    umask u+rwx,g+rwx,o-rwx && \
    export PY_VER=$(python -c "import sys;print(sys.version)" | \
        head -1 | awk '{print $1}') && \
    # conda install -yc conda-forge python=$PY_VER jupyterlab && \
    /entrypoint.sh echo "Requirements updated..." && \
    rm $APK_REQUIREMENTS && \
    rm $PIP_REQUIREMENTS && \
    pip install /src && \
    rm /src/* && \
    conda clean -ya && \
    find /opt/conda/conda-meta -user dja -exec chmod u+rwx,g+rwx,o-rwx "{}" \; && \
    chmod -R o+w /home/dja/.cache
ENV DJLAB_CONFIG /tmp/djlab_config.yaml
COPY --chown=dja:anaconda ./config/jupyter_notebook_config.py /etc/jupyter/
COPY --chown=dja:anaconda ./config/ipython_config.py /etc/ipython/
COPY --chown=dja:anaconda ./config/djlab_config.yaml /tmp/
COPY ./utilities/entrypoint.sh /entrypoint.sh

# #Squashed Final Image
FROM scratch
COPY --from=jup_build / /
RUN chmod 4755 /startup && /startup -user=dja
LABEL maintainerName="Raphael Guzman" \
      maintainerEmail="raphael@vathes.com" \
      maintainerCompany="DataJoint"
USER dja:anaconda
ENV HOME /home/dja
ENV LANG C.UTF-8
ENV APK_REQUIREMENTS /tmp/apk_requirements.txt
ENV PIP_REQUIREMENTS /tmp/pip_requirements.txt
ENV CONDA_REQUIREMENTS /conda_requirements.txt
ENV DJLAB_CONFIG /tmp/djlab_config.yaml
ENV PATH "/home/dja/.local/bin:/opt/conda/bin:$PATH"
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /home/dja
VOLUME /home/dja
VOLUME /tmp/.X11-unix
EXPOSE 8888
CMD ["jupyter", "lab"]