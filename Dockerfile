# Use latest jboss/base-jdk:8 image as the base
FROM jboss/base-jdk:8

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 15.0.0.Alpha1-SNAPSHOT
#ENV WILDFLY_SHA1 757d89d86d01a9a3144f34243878393102d57384
ENV JBOSS_HOME /opt/jboss/wildfly

USER root

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
RUN cd $HOME \
    && curl -O https://ci.wildfly.org/repository/download/WF_Nightly/125945:id/wildfly-$WILDFLY_VERSION.zip -u guest:guest \
    && unzip wildfly-$WILDFLY_VERSION.zip \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.zip \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

RUN yum install epel-release -y
RUN yum install jq -y

ARG APP_FILE=appfile.war
# Add your application to the deployment folder
ADD ${APP_FILE} /opt/jboss/wildfly/standalone/deployments/${APP_FILE}
# Add standalone-ha.xml - set your own network settings
ADD standalone-ha.xml /opt/jboss/wildfly/standalone/configuration/standalone-ha.xml
# Add user for adminstration purpose
RUN /opt/jboss/wildfly/bin/add-user.sh admin admin123 --silent

# Add entrypoint.sh
COPY entrypoint.sh /
USER jboss
ENTRYPOINT ["/entrypoint.sh"]
