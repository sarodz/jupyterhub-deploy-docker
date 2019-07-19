ARG DOCKER_NOTEBOOK_IMAGE
FROM $DOCKER_NOTEBOOK_IMAGE
#any additional installations go here.
ARG DISPLAY
ENV DISPLAY=$DISPLAY
ARG JUPYTERHUB_VERSION
ENV JUPYTERHUB_VERSION=$JUPYTERHUB_VERSION

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

# If you do not need parallelism, delete the following. 
# RUN python3 -m pip install ipyparallel mpi4py
# RUN ipython profile create --parallel --profile=mpi
# RUN ipython profile create --parallel --profile=default
# RUN echo "c.IPClusterEngines.engine_launcher_class = 'MPIEngineSetLauncher'" >> /home/jovyan/.ipython/profile_mpi/ipcluster_config.py

# Python 2 environment
# RUN conda create --quiet --yes -p $CONDA_DIR/envs/python2 python=2.7 pip ipython ipykernel kernda numpy pandas matplotlib ipywidgets yaml ipyparallel mpi4py scipy pyDOE 
# RUN /opt/conda/envs/python2/bin/ipython profile create --parallel --profile=mpi
# RUN /opt/conda/envs/python2/bin/ipython profile create --parallel --profile=default

USER root
# Create a global kernelspec in the image and modify it so that it properly activates
# the python2 conda environment.
# RUN $CONDA_DIR/envs/python2/bin/python -m ipykernel install && \
# $CONDA_DIR/envs/python2/bin/kernda -o -y /usr/local/share/jupyter/kernels/python2/kernel.json

RUN apt-get -qq update && apt-get install --yes --no-install-recommends texlive texlive-latex-base texlive-latex-recommended texlive-science texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra dvipng lmodern ghostscript context texlive-xetex texlive-luatex fonts-lato vim qrencode && apt-get -qq purge && apt-get -qq clean && rm -rf /var/lib/apt/lists/*

USER $NB_UID
# Jupyterhub and memory monitoring
RUN conda install --yes -c conda-forge jupyter_contrib_nbextensions ipywidgets
RUN python3 -m pip install --no-cache jupyterhub==$JUPYTERHUB_VERSION nbresuse && \
    jupyter labextension install jupyterlab-topbar-extension && \
    jupyter labextension install jupyterlab-system-monitor && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \ 
    jupyter labextension install @jupyterlab/git && \
    python3 -m pip install --upgrade jupyterlab-git && \
    jupyter serverextension enable --py jupyterlab_git && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER


# USER SETTINGS
USER jovyan
RUN echo ". /home/jovyan/work/.bash_custom" >> /home/jovyan/.bashrc
RUN echo "export EDITOR=/usr/bin/vim" >> /home/jovyan/.bashrc
RUN echo "export PAGER=less" >> /home/jovyan/.bashrc
RUN jupyter nbextension enable snippets_menu/main && \
    jupyter nbextension enable codefolding/main && \
    jupyter nbextension enable codefolding/edit && \
    jupyter nbextension enable execute_time/ExecuteTime && \
    jupyter nbextension enable notify/notify && \
    jupyter nbextension enable rubberband/main && \
    jupyter nbextension enable varInspector/main && \
    jupyter nbextension enable latex_envs/latex_envs && \
    jupyter nbextension enable load_tex_macros/main && \
    jupyter nbextension enable toc2/main

# HUGO
USER root
ENV HUGO_VER=0.53
RUN wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VER}/hugo_${HUGO_VER}_Linux-64bit.deb
RUN dpkg -i hugo*.deb
RUN rm hugo*.deb 

USER jovyan
# Python 3.6 environment
RUN conda create --quiet --yes -n py3 python=3.6 pip ipython ipykernel kernda numpy ipywidgets
RUN /opt/conda/envs/py3/bin/pip install vpython==7.4.0
RUN /opt/conda/envs/py3/bin/python -m ipykernel install --user --name myenv --display-name "Python3.6"
RUN echo "# config file" >> /home/jovyan/work/.bash_custom
