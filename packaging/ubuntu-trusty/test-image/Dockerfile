FROM ubuntu:trusty
ADD artifacts/setup_tests /tmp/setup_tests
ADD artifacts/run_tests /usr/bin/run_tests
ADD artifacts/*.deb /tmp
RUN dpkg -i /tmp/*.deb
RUN /tmp/setup_tests
USER nobody
ENV HOME /no/existing/home/directory
