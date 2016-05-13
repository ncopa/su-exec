FROM ubuntu:trusty
ADD setup_tests /tmp/setup_tests
ADD run_tests /usr/bin/run_tests
ADD *.deb /tmp
RUN /tmp/setup_tests
USER nobody
ENV HOME /no/existing/home/directory
