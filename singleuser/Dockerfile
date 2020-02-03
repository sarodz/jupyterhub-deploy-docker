ARG DOCKER_NOTEBOOK_IMAGE
ARG DISPLAY
FROM $DOCKER_NOTEBOOK_IMAGE
ARG JUPYTERHUB_VERSION
#any additional installations go here.
RUN export DISPLAY=$DISPLAY

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    vim \
    htop \
    fonts-dejavu \
    tzdata \
    gfortran \
    gcc

# finish off with MPI dependencies (only required if not installing fenics)
#RUN sudo apt-get install mpich libmpich-dev -y
RUN rm -rf /var/lib/apt/lists/*

USER jovyan
RUN conda update --all
RUN conda install fenics
#RUN conda install nodejs -c conda-forge

# If you do not need parallelism, delete the following. 
RUN python3 -m pip install ipyparallel mpi4py
RUN ipython profile create --parallel --profile=mpi
RUN ipython profile create --parallel --profile=default
RUN echo "c.IPClusterEngines.engine_launcher_class = 'MPIEngineSetLauncher'" >> /home/jovyan/.ipython/profile_mpi/ipcluster_config.py

USER $NB_UID
# Jupyterhub and memory monitoring
RUN python3 -m pip install --no-cache jupyterhub==$JUPYTERHUB_VERSION nbresuse && \
    jupyter labextension install --minimize=False jupyterlab-topbar-extension \
                                 jupyterlab-system-monitor \
                                 jupyterlab-theme-toggle && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# USER SETTINGS
USER jovyan
RUN echo "export EDITOR=/usr/bin/vim" >> /home/jovyan/.bashrc
