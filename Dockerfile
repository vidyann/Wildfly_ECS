# Use latest jboss/base-jdk:8 image as the base
FROM jboss/base-jdk:8

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 15.0.0.Final
ENV WILDFLY_SHA1 a387f2ebf1b902fc09d9526d28b47027bc9efed9
ENV JBOSS_HOME /opt/jboss/wildfly

USER root

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
RUN cd $HOME \
    && curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
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
