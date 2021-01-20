ARG VERSION

FROM ghcr.io/riverlane/deltaflow-on-artiq:${VERSION}

ARG USERNAME
ARG USER_UID
ARG USER_GID

ENV DEBIAN_FRONTEND=noninteractive

USER root 

# Create the user
RUN (groupadd --gid $USER_GID $USERNAME; exit 0) && \
    (useradd --uid $USER_UID --gid $USER_GID -m $USERNAME; exit 0) && \
    mkdir -p /home/$USERNAME/.vscode-server /home/$USERNAME/.vscode-server-insiders && \
    chown ${USER_UID}:${USER_GID} /home/$USERNAME/.vscode-server*

# Add sudo support to install extra software if needed
RUN apt-get install -y sudo && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Clean up
RUN apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Switch to the user
USER $USERNAME

ENV DEBIAN_FRONTEND=dialog 
ENV PYTHONPATH=/workdir/:${PYTHONPATH}:/workdir
