ARG DOCKERREPO=docker.io
FROM $DOCKERREPO/centos:7

# IMPORT the Centos-7 GPG key to prevent warnings
RUN rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7

# Add bintray repository where the SBT binaries are published
RUN curl -sS https://bintray.com/sbt/rpm/rpm | tee /etc/yum.repos.d/bintray-sbt-rpm.repo

# Base Install + JDK
RUN yum -y update && \
    yum -y install java-1.8.0-openjdk && \
    yum -y install java-1.8.0-openjdk-devel && \
    yum -y install sudo && \
    yum -y install sbt && \
    yum -y update bash && \
    yum -y install git && \
    yum -y install initscripts && \
    yum -y install telnet-server && \
    rm -rf /var/cache/yum/* && \
    yum clean all


#Install Docker inside this container
RUN curl -fsSL https://get.docker.com/ | sh

#add your username to the docker group:
RUN sudo usermod -aG docker $(whoami)

# Install Jenkins
ENV JENKINS_HOME /opt/jenkins/data
ENV JENKINS_MIRROR http://mirrors.jenkins-ci.org

RUN yum -y install wget 
RUN wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
RUN rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
RUN yum -y install jenkins

RUN mkdir -p $JENKINS_HOME/plugins
RUN curl -sf -o /opt/jenkins/jenkins.war -L $JENKINS_MIRROR/war-stable/latest/jenkins.war

RUN for plugin in authentication-tokens pipeline-stage-tags-metadata script-security timestamper pipeline-model-definition pipeline-github-lib pipeline-input-step git-client subversion jsch email-ext structs docker-workflow jackson2-api ant handlebars matrix-auth ldap workflow-api pipeline-build-step mailer resource-disposer pipeline-stage-step apache-httpcomponents-client-4-api credentials-binding pam-auth ssh-credentials ace-editor ws-cleanup pipeline-milestone-step scm-api github-branch-source workflow-step-api docker-commons git workflow-basic-steps plain-credentials pipeline-model-declarative-agent durable-task workflow-durable-task-step ssh-slaves gradle workflow-support pipeline-rest-api git-server matrix-project windows-slaves mapdb-api pipeline-model-api branch-api display-url-api workflow-job bouncycastle-api pipeline-stage-view github cloudbees-folder workflow-aggregator github-api workflow-cps credentials pipeline-model-extensions build-timeout workflow-cps-global-lib junit momentjs antisamy-markup-formatter jquery-detached token-macro pipeline-graph-analysis workflow-multibranch workflow-scm-step cobertura ;\
    do curl -sf -o $JENKINS_HOME/plugins/${plugin}.hpi \
       -L $JENKINS_MIRROR/plugins/${plugin}/latest/${plugin}.hpi ; done


EXPOSE 9001
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

CMD java -Djenkins.install.runSetupWizard=false -jar /opt/jenkins/jenkins.war

#259191cab8214a45838260e676a2eb0c
