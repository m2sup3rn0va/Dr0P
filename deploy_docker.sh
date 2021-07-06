#! /bin/bash

echo 'Please be patient....'
sudo apt-get clean
sudo apt-get update --fix-missing &> /dev/null
sudo apt-get install -y lolcat > /dev/null
if [[ $? != 0 ]];
then
    echo '[-]: Not able to install LOLCAT' | lolcat
    exit
fi
tput clear reset

docker ps -a &> /dev/null

if [[ $? == 0 ]];
then
    echo ''
    echo '[I]: Building Dr0p Image' | lolcat
    echo '[I]: This is going to take some time.....' | lolcat
    
    echo ''
    docker build . | lolcat
    if [[ $? == 0 ]];
    then
        echo ''
        echo '[I]: Creating Docker Container' | lolcat
        imageID=$(docker images -a | awk -F' ' 'FNR == 2 { print $3 }')
        docker tag $imageID dr0p:v1
        
        docker create -it --name "dr0p" --hostname "dr0p" --device=/dev/kvm -u user -w /home/user/ -v $HOME/Dr0p/shareDrive/:/home/user/shareDrive --net=host --dns="8.8.8.8" --dns="4.2.2.2" --add-host="dr0p:127.0.0.2" --shm-size=8g -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/:ro -v $HOME/.Xauthority:/home/user/.Xauthority:ro -v /dev/bus/usb:/dev/bus/usb -v /var/run/usbmuxd:/var/run/usbmuxd dr0p:v1 &> /dev/null

        if [[ $? == 0 ]];
        then
            echo ''
            docker ps -a | lolcat
            echo ''
            echo "[+]: Container Created" | lolcat
            echo ''
            echo "[+]: To Start the Container - docker start dr0p" | lolcat
            echo "[+]: To Stop the Container - docker stop dr0p" | lolcat
            echo "[+]: To get shell of the Container - docker exec -it dr0p bash" | lolcat
            echo ''
        else
            echo ''
            docker ps -a | lolcat
            echo ''
            echo "[-]: Error creating the Container" | lolcat
            echo ''
            exit
        fi
    else
        echo '[I]: Please re-run the script' | lolcat
        echo ''
        exit
    fi
else
    echo "[I]: Installing Dependencies" | lolcat
    echo ''
    sudo apt-get clean | lolcat &&
    sudo apt-get autoclean | lolcat &&
    echo ''
    sudo apt-get remove -y | lolcat &&
    echo ''
    sudo apt-get autoremove -y | lolcat &&
    echo ''
    sudo apt-get update --fix-missing | lolcat &&
    echo ''
    sudo apt-get install docker docker.io usbutils libusbmuxd-tools libimobiledevice6 libimobiledevice-utils ideviceinstaller -y | lolcat &&
    echo ''
    sudo apt-get update --fix-missing | lolcat

    echo ''
    sudo usermod -aG docker $USER &> /dev/null
    echo '[I]: User added to docker group' | lolcat
    cat /etc/group | grep docker | lolcat

    echo ''
    echo '[I]: Creating Docker Share Drive' | lolcat
    mkdir -p $HOME/Dr0P/shareDrive &> /dev/null
    echo -e "[+]: Share Drive Created : $HOME/Dr0P/shareDrive" | lolcat

    echo ''
    echo '[I]: Checking KVM Status' | lolcat
    ls -al /dev/kvm &> /dev/null
    if [[ $? == 0 ]];
    then
        echo "[+]: KVM Found : /dev/kvm" | lolcat
    else
        echo "[-]: VT-x/AMD-V Not Enabled in BIOS" | lolcat
        exit
    fi
    
    echo ""
    echo '[I]: DOCKER INSTALLED SUCCESSFULLY' | lolcat
    echo '[I]: PLEASE LOGOUT AND LOGIN BACK AND RE-RUN THE SCRIPT' | lolcat
    echo ""
fi
