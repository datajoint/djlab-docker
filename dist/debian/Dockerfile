ARG PY_VER

from raphaelguzman/djbase:py${PY_VER}-debian as jup_build
USER dja:anaconda

RUN \
    umask u+rwx,g+rwx,o-rwx && \
    export PY_VER=$(python -c "import sys;print(sys.version)" | head -1 | awk '{print $1}') && \
    # conda install -yc conda-forge python=$PY_VER jupyterlab && \
    pip install --no-cache-dir jupyterlab && \
    conda clean -ya && \
    find /opt/conda/conda-meta -user dja -exec chmod u+rwx,g+rwx,o-rwx "{}" \; && \
    chmod -R o+w /home/dja/.cache
COPY ./config/jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

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
ENV APT_REQUIREMENTS /apt_requirements.txt
ENV PIP_REQUIREMENTS /pip_requirements.txt
ENV CONDA_REQUIREMENTS /conda_requirements.txt
ENV PATH "/home/dja/.local/bin:/opt/conda/bin:$PATH"
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /home/dja
VOLUME /home/dja
VOLUME /tmp/.X11-unix
EXPOSE 8888
CMD ["jupyter", "lab"]