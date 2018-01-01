FROM ubuntu

# Install openssh
RUN apt-get update && apt-get install -y openssh-server python python-mysqldb
RUN mkdir /var/run/sshd
RUN sed 's/#PasswordAuthentication yes/PasswordAuthentication no/' -i /etc/ssh/sshd_config
RUN sed 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' -i /etc/pam.d/sshd
RUN /usr/bin/ssh-keygen -A

# Add powerdyn user
RUN useradd -m powerdyn
RUN chown powerdyn:powerdyn /home/powerdyn
USER powerdyn
WORKDIR /home/powerdyn

# Load in ssh key
RUN mkdir .ssh
RUN chmod 0700 .ssh
COPY --chown=powerdyn:powerdyn powerdns_rsa.pub .ssh/authorized_keys
RUN chmod 0600 .ssh/authorized_keys
USER powerdyn

# Receive args from our parent
ARG MYSQL_HOST
ARG MYSQL_USER
ARG MYSQL_PASSWORD
ARG DOMAIN

# generate .powerdyn.conf
RUN echo "\
[powerdyn]\n\
domain = ${DOMAIN}\n\
dbtype = mysql\n\
dbhost = ${MYSQL_HOST}\n\
dbname = ${MYSQL_USER}\n\
dbuser = ${MYSQL_USER}\n\
dbpass = ${MYSQL_PASSWORD}\n\
" > .powerdyn.conf

# Copy in powerdyn
COPY --chown=powerdyn:powerdyn powerdyn powerdyn

# By default, we run openssh
WORKDIR /
USER root
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
