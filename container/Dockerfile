FROM qmstr/runtime as demobase
# install runtime deps
COPY --from=qmstr/master_build /usr/local/bin/qmstr /usr/local/bin/qmstr
COPY --from=qmstr/master_build /usr/local/bin/qmstr-wrapper /usr/local/bin/qmstr-wrapper
COPY --from=qmstr/master_build /usr/local/bin/qmstrctl /usr/local/bin/qmstrctl

ENV GOPATH /go
ENV PATH ${GOPATH}/bin:/usr/lib/go-1.9/bin:$PATH

VOLUME /go/src

# java base projects deps
FROM openjdk as javabuilder

RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/QMSTR/qmstr-gradle-plugin.git

RUN mkdir -p .gradle/$(grep zipStorePath /qmstr-gradle-plugin/gradle/wrapper/gradle-wrapper.properties | cut -d "=" -f2)
RUN cd .gradle/$(grep zipStorePath /qmstr-gradle-plugin/gradle/wrapper/gradle-wrapper.properties | cut -d "=" -f2) && wget $(grep distributionUrl /qmstr-gradle-plugin/gradle/wrapper/gradle-wrapper.properties | cut -d "=" -f2 |sed -e 's#\\##')

RUN cd qmstr-gradle-plugin && ./gradlew install

FROM demobase as javademobase

RUN apt-get update
RUN apt-get install -y openjdk-8-jdk openjfx

RUN mkdir -p /maven/conf
ENV M2_HOME /maven

ADD settings.xml /maven/conf/settings.xml

COPY --from=javabuilder /root/.m2/repository /maven/repo

RUN chmod -R 777 /maven/repo