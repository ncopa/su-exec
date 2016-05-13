FROM fedora:23
ADD artifacts/setup_tests /tmp/setup_tests
ADD artifacts/run_tests /usr/bin/run_tests
ADD artifacts/*.rpm /tmp
RUN yum -y install /tmp/*.rpm
RUN yum -y install findutils
RUN /tmp/setup_tests
USER nobody
ENV HOME /no/existing/home/directory
