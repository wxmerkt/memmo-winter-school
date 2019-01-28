FROM ros:melodic-ros-core

RUN apt-get update
RUN apt-get install curl nano -y
RUN sh -c "echo 'deb [arch=amd64] http://robotpkg.openrobots.org/packages/debian/pub bionic robotpkg' >> /etc/apt/sources.list.d/robotpkg.list"
RUN curl http://robotpkg.openrobots.org/packages/debian/robotpkg.key | apt-key add -
RUN apt-get update 
RUN apt install robotpkg-py27-pinocchio -y
RUN apt install robotpkg-gepetto-viewer-corba -y

RUN sh -c "echo 'export PATH=/opt/openrobots/bin:$PATH' >> /root/.bashrc"
RUN sh -c "echo 'export PKG_CONFIG_PATH=/opt/openrobots/lib/pkgconfig:$PKG_CONFIG_PATH' >> /root/.bashrc"
RUN sh -c "echo 'export LD_LIBRARY_PATH=/opt/openrobots/lib:$LD_LIBRARY_PATH' >> /root/.bashrc"
RUN sh -c "echo 'export PYTHONPATH=/opt/openrobots/lib/python2.7/site-packages:$PYTHONPATH' >> /root/.bashrc"

RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd

RUN echo 'root:root' |chpasswd

RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^#?X11UseLocalhost\s+.*/X11UseLocalhost no/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN mkdir /root/.ssh

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

RUN apt-get update

RUN apt-get install -y python-pip
RUN pip install jupyter ipykernel matplotlib scipy numpy
RUN apt-get install -y python-tk
RUN apt-get install robotpkg-py27-eigenpy

RUN apt-get install -y libeigen3-dev cmake
RUN git clone --recursive https://github.com/stack-of-tasks/tsid.git
RUN . /root/.bashrc && mkdir -p /tsid/_build-RELEASE && cd /tsid/_build-RELEASE && cmake .. -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/opt/openrobots && make install
RUN rm -rf /tsid/_build-RELEASE

RUN sh -c "echo '#!/bin/bash' >> /usr/bin/notebook" && sh -c "echo 'jupyter notebook --no-browser --ip=0.0.0.0 --allow-root' >> /usr/bin/notebook" && chmod +x /usr/bin/notebook
RUN sh -c "echo '#!/bin/bash' >> /cmd.sh" && sh -c "echo 'service omniorb4-nameserver start' >> /cmd.sh" && sh -c "echo 'service ssh start && cd /develop && /bin/bash' >> /cmd.sh" && chmod +x /cmd.sh

EXPOSE 8888

CMD ["/cmd.sh"]
