sudo snap remove firefox
sudo apt-get purge firefox
sudo add-apt-repository ppa:mozillateam/ppa
sudo apt-get update
echo '
Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 501
' | sudo tee /etc/apt/preferences.d/mozillateamppa
sudo apt-get install firefox
