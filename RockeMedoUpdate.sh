#!/bin/bash

if ! command -v screen &> /dev/null; then
  sudo apt-get install -y screen
fi

highlight() {
  echo -e "\e[1;35m$1\e[0m" 
}

# Maskiert NGINX

sudo systemctl mask nginx.serivce

# Setze Skript im Fehlerfall auf Abbruch
set -e

echo "Überprüfe, ob Zabbix Agent in /opt installiert ist..."

if [ -e /etc/zabbix/zabbix_agentd.conf ]; then
    echo "Zabbix agent wird dank dem script nicht funktionieren! Bitte Timo Frings Bescheid geben."
    exit 1
fi

# Empty line for spacing
echo
echo "Zabbix Agent nicht installiert oder in /opt installiert, fahre fort..."
echo

# Setze Skript im Fehlerfall auf Abbruch
set -e

highlight "Starte System-Update für Debian..."

# Stelle sicher, dass 'sl' installiert ist
#if ! command -v sl &> /dev/null; then
#  sudo apt-get install -y sl
#fi

# Starte 'sl' als Ladeanimation
echo
highlight "Loading... 🚂"
echo
#sl

# Entferne alte buster-backports-Einträge und füge sie erneut hinzu
echo
highlight "Konfiguriere die Quellenliste..."
echo
sudo sed -i '/buster-backports/d' /etc/apt/sources.list
echo "deb http://archive.debian.org/debian buster-backports main contrib non-free" | sudo tee -a /etc/apt/sources.list

# Aktualisiere die Paketliste
echo
highlight "Aktualisiere die Paketliste..."
echo
sudo apt-get update

# Vollständiges System-Upgrade
highlight "Führe System-Upgrade aus..."
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade

# Installiere fehlende Abhängigkeiten
highlight "Behebe Abhängigkeitsprobleme..."
sudo apt --fix-broken install -y

# Lade Systemd neu
highlight "Systemd neu laden..."
sudo systemctl daemon-reload

# Installiere Oracle Java 21
highlight "Installiere Oracle JDK 21..."
wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb
sudo dpkg -i jdk-21_linux-x64_bin.deb

# Konfiguriere Java-Version
highlight "Konfiguriere Java..."
sudo update-java-alternatives -s /usr/lib/jvm/jdk-21.0.5-oracle-x64/

# Prüfe auf fehlerhafte Dienst
highlight "Prüfe Systemd auf fehlerhafte Dienste..."
sudo systemctl --failed


# Docker neustart
sudo systemctl restart docker.service
sudo systemctl restart docker.socket
highlight Mowoli wird neugestartet 

# X11VNC Restart + Session
sudo systemctl restart x11vnc
# x11vnc -ncache

# Abschlussmeldung
echo
echo -e "\e[32m✔️ Debian-System-Update abgeschlossen! Du hast es an dich geglaubt und es geschafft Tomedo zu Fixen! Das System wird nun neu gestartet.\e[0m"
echo
# Neustart des Systems
sudo reboot
