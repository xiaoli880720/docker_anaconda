FROM ubuntu
LABEL author='ENVUSER'

RUN apt-get clean && apt-get update --fix-missing
RUN apt-get update && apt-get upgrade

RUN useradd -ms /bin/bash ENVUSER && \
adduser ENVUSER sudo && \
echo "ENVUSER:0"|chpasswd && \
echo "root:0"|chpasswd

ENV HOME /home/ENVUSER
ENV HOSTNAME envserver
WORKDIR /home/ENVUSER

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get install -y apt-utils sudo vim iproute2 wget

RUN apt-get install -y openssh-server

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    echo 'sshd:ALL' >> /etc/hosts.aldlow

EXPOSE 22

RUN apt-get autoclean && apt-get autoremove

USER ENVUSER

RUN wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh -O ~/conda.sh

RUN /bin/bash ~/conda.sh -b -p ~/conda && \
    rm ~/conda.sh

RUN echo '\n\
__conda_setup="$('/home/ENVUSER/conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"\n\
if [ $? -eq 0 ]; then\n\
    eval "$__conda_setup"\n\
else\n\
    if [ -f "/home/ENVUSER/conda/etc/profile.d/conda.sh" ]; then\n\
        . "/home/ENVUSER/conda/etc/profile.d/conda.sh"\n\
    else\n\
        export PATH="/home/ENVUSER/conda/bin:$PATH"\n\
    fi\n\
fi\n\
unset __conda_setup\n'\
>> ~/.bashrc && \
    /bin/bash -c 'source  ~/.bashrc'

ENTRYPOINT sudo service ssh start && /bin/bash