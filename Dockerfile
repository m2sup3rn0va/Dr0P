FROM ubuntu:latest
MAINTAINER Mr. Sup3rN0va | @m2sup3rn0va <m2sup3rn0va@gmail.com>

# Build time arguments
ARG DEBIAN_FRONTEND=noninteractive

# Create New User
RUN adduser --disabled-password --gecos '' user && \
echo "user:user" | chpasswd && \
echo "root:toor" | chpasswd

# Installing Packages
RUN apt-get clean -y && \
apt-get autoclean -y && \
apt-get remove -y && \
apt-get autoremove -y && \
apt-get update -y && \
apt-get install --yes --no-install-recommends apt-utils && \
apt-get install --yes --no-install-recommends apt-transport-https && \
apt-get install --yes --no-install-recommends net-tools iputils-ping wget curl && \
apt-get install --yes --no-install-recommends openjdk-14-jdk openjdk-14-jre libpulse0 libxcomposite1 && \
apt-get install --yes --no-install-recommends git ruby aapt zipalign unzip bat tzdata && \
apt-get install --yes --no-install-recommends libvirt-clients bridge-utils xz-utils libxcursor1 && \
apt-get install --yes --no-install-recommends libvirt-daemon-system libqt5dbus5 libqt5widgets5 && \
apt-get install --yes --no-install-recommends libqt5network5 libqt5gui5 libqt5core5a && \
apt-get install --yes --no-install-recommends libdouble-conversion3 libxcb-xinerama0 && \
apt-get install --yes --no-install-recommends usbutils libusbmuxd-tools libimobiledevice6 && \
apt-get install --yes --no-install-recommends libimobiledevice-utils ideviceinstaller && \
apt-get install --yes --no-install-recommends python2 python3-pip python3-venv vim && \
apt-get install --yes --no-install-recommends qemu-kvm sudo xauth tmux neofetch bash-completion && \
rm -rf /var/lib/apt/lists/*

RUN echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
usermod -aG sudo user && \
echo "Asia/Kolkata" > /etc/timezone

# Installing Python2-PIP
RUN wget -q https://bootstrap.pypa.io/pip/2.7/get-pip.py && \
python2 get-pip.py && \
rm -rf get-pip.py

USER user

# Dependencies for RASEv2
RUN python3 -m pip install -U pip rich pyqt5 pyqt5-tools bs4 wget --user --no-warn-script-location

# Dependencies for Drozer
RUN python2 -m pip install protobuf pyopenssl twisted --user --no-warn-script-location

# =======================================================================================================================

# Installing Custom Terminal

## Installing LOLCAT
RUN git clone https://github.com/busyloop/lolcat.git /home/user/lolcat && \
cd /home/user/lolcat/bin && \
sudo gem install lolcat && \
rm -rf /home/user/lolcat

## APT-UPDATE

COPY scripts/apt-update /home/user/.local/bin/apt-update
RUN sudo chown -R user:user /home/user/.local/bin/apt-update && \
chmod +x /home/user/.local/bin/apt-update

## Copy My Profile
COPY scripts/my_profile /home/user/.my_profile
RUN sudo chown -R user:user /home/user/.my_profile && \
echo "source /home/user/.my_profile" >> /home/user/.bashrc && \
echo "source /home/user/.bashrc" > /home/user/.bash_profile

## Copy VIMRC
COPY scripts/vimrc /home/user/.vimrc
RUN sudo chown -R user:user /home/user/.vimrc

## POWERLINE for Bash
RUN sudo chown -R user:user /home/user && \
mkdir -p /home/user/.local/lib && \
python3 -m pip install -U pip powerline-shell --user --no-warn-script-location && \
echo '\nfunction _update_ps1()\n{\n  PS1=$(powerline-shell $?)\n}\nif [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then\n   PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"\nfi' >> /home/user/.bashrc

## Copy TMUX
RUN mkdir -p /home/user/.tmux
COPY scripts/tmux.conf /home/user/.tmux/tmux.conf
RUN sudo chown -R user:user /home/user/.tmux/tmux.conf && \
git clone --progress https://github.com/arcticicestudio/nord-tmux.git /home/user/.tmux/nord-tmux && \
git clone --progress https://github.com/wfxr/tmux-power.git /home/user/.tmux/tmux-power && \
git clone --progress https://github.com/tmux-plugins/tmux-net-speed.git /home/user/.tmux/tmux-net-speed

## Copy EXA
RUN mkdir -p /home/user/exa && \
wget -q https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip -O /home/user/exa/exa.zip && \
cd /home/user/exa && \
unzip exa.zip && \
rm -rf completions man && \
mv -f bin/exa /home/user/.local/bin/ && \
chmod +x /home/user/.local/bin/exa && \
cd /home/user && rm -rf /home/user/exa

## Copy Procs
RUN mkdir -p /home/user/procs && \
wget -q https://github.com/dalance/procs/releases/download/v0.11.9/procs-v0.11.9-x86_64-lnx.zip -O /home/user/procs/procs.zip && \
cd /home/user/procs && \
unzip procs.zip && \
mv -f /home/user/procs/procs /home/user/.local/bin/procs && \
chmod +x /home/user/.local/bin/procs && \
cd /home/user && rm -rf /home/user/procs

# =======================================================================================================================

## TOOLS INSTALLATION

# Setting up Android Emulator
# Need Manual Installation
COPY tools/android-studio.tar.gz /home/user/
RUN tar -xvf /home/user/android-studio.tar.gz -C /home/user && \
mv -f /home/user/android-studio /home/user/.android-studio && \
chmod +x /home/user/.android-studio/bin/studio.sh && \
rm -rf /home/user/android-studio.tar.gz

# Setting OWASP ZAP
COPY tools/zap.tar.gz /home/user/
RUN mkdir -p /home/user/.local/tools/ZAP && tar -xvf /home/user/zap.tar.gz -C /home/user/.local/tools/ZAP --strip-components 1 && \
chmod +x /home/user/.local/tools/ZAP/zap.sh && \
ln -s /home/user/.local/tools/ZAP/zap.sh /home/user/.local/bin/zap && \
rm -rf /home/user/zap.tar.gz

# Installing RASEv2
COPY tools/RASEv2-Linux.tar.xz /home/user/
RUN sudo chown -R user:user /home/user && \
cd /home/user && \
tar -xvf /home/user/RASEv2-Linux.tar.xz -C /home/user && \
rm -rf /home/user/RASEv2-Linux.tar.xz

# Installing Frida and other tools
RUN python3 -m pip install -U frida frida-tools objection --user --no-warn-script-location

# Installing PIDCAT
RUN mkdir -p /home/user/.local/tools/pidcat && \
cd /home/user/.local/tools/pidcat && \
wget https://raw.githubusercontent.com/JakeWharton/pidcat/master/pidcat.py
COPY scripts/pidcat /home/user/.local/bin/pidcat
RUN sudo chown -R user:user /home/user && \
chmod +x /home/user/.local/bin/pidcat

# Installing APKTOOL
RUN mkdir -p /home/user/.local/tools/apktool && \
cd /home/user/.local/tools/apktool && \
wget -q https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.5.0.jar -O apktool.jar
COPY scripts/apktool /home/user/.local/bin/apktool
RUN sudo chown -R user:user /home/user && \
chmod +x /home/user/.local/bin/apktool

# Installing Bytecode Viewer
RUN mkdir -p /home/user/.local/tools/ByteCodeViewer && \
cd /home/user/.local/tools/ByteCodeViewer && \
wget -q https://github.com/Konloch/bytecode-viewer/releases/download/v2.9.22/Bytecode-Viewer-2.9.22.jar -O ByteCodeViewer.jar
COPY scripts/bytecode-viewer /home/user/.local/bin/bytecode-viewer
RUN sudo chown -R user:user /home/user && \
chmod +x /home/user/.local/bin/bytecode-viewer

# Installing Drozer
RUN mkdir -p /home/user/.local/tools/Drozer && \
cd /home/user/.local/tools/Drozer && \
echo "INFO: DOWNLOADING DROZER" && \
wget -q https://github.com/FSecureLABS/drozer/releases/download/2.4.4/drozer-2.4.4.tar.gz -O drozer.tar.gz && \
echo "INFO: DOWNLOADING DROZER AGENT" && \
wget -q https://github.com/mwrlabs/drozer/releases/download/2.3.4/drozer-agent-2.3.4.apk -O drozer-agent.apk && \
tar -xvf drozer.tar.gz && \
rm -rf drozer.tar.gz && \
chmod +x drozer-2.4.4/bin/drozer
COPY scripts/drozer /home/user/.local/bin/drozer
RUN sudo chown -R user:user /home/user && \
chmod +x /home/user/.local/bin/drozer

# Installing NodeJS and NPM
RUN curl -fsSL https://deb.nodesource.com/setup_12.x | sudo -E bash - && \
sudo apt-get install -y nodejs

# Installing RMS
RUN git clone --progress https://github.com/m0bilesecurity/RMS-Runtime-Mobile-Security.git /home/user/.local/tools/RMS && \
cd /home/user/.local/tools/RMS && npm install
COPY scripts/rms /home/user/.local/bin/rms
RUN sudo chown -R user:user /home/user && \
chmod +x /home/user/.local/bin/rms

# Installing MobSF
RUN git clone --progress https://github.com/MobSF/Mobile-Security-Framework-MobSF.git /home/user/.local/tools/MobSF && \
cd /home/user/.local/tools/MobSF && \
python3 -m pip install -r requirements.txt --user --no-warn-script-location && \
chmod +x setup.sh && \
/bin/bash setup.sh
COPY scripts/mobsf /home/user/.local/bin/mobsf
RUN sudo chown -R user:user /home/user && \
chmod +x /home/user/.local/bin/mobsf
