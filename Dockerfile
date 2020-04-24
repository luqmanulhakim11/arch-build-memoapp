FROM scratch
ADD archlinux.tar /
RUN mkdir /var/run/sshd

ENV HOME /home/me

RUN useradd --create-home --home-dir $HOME -s /usr/bin/fish me && chown -R me $HOME

RUN echo me:password | chpasswd
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
RUN ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa

RUN mkdir $HOME/projects && chown -R me:me $HOME/projects

ENV LANG=en_US.UTF-8
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
