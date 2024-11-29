#!/bin/bash

highlight() {
  echo -e "\e[1;35m$1\e[0m" 
}

# Prüfen, ob Nginx läuft
if systemctl is-active --quiet nginx; then
    highlight "Nginx läuft. Server wird aufgrund von Nginx neu gestartet."
    
    # Nginx maskieren (deaktivieren und verhindern, dass es gestartet wird)
    sudo systemctl mask nginx
    echo
    highlight "Nginx wurde maskiert."
    echo

    # Server neustarten
    echo
    highlight "Server wird jetzt neu gestartet..."
    echo
    sudo reboot
else
    highlight "Nginx läuft nicht. Skript fährt fort."
fi

# Setze Skript im Fehlerfall auf Abbruch

if ! command -v screen &> /dev/null; then
  sudo apt-get install -y screen
fi

set -e
echo
echo "Überprüfe, ob Zabbix Agent in /opt installiert ist..."
echo

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
echo
highlight "Führe System-Upgrade aus..."
echo
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade

# Installiere fehlende Abhängigkeiten
echo
highlight "Behebe Abhängigkeitsprobleme..."
echo
sudo apt --fix-broken install -y

# Lade Systemd neu
echo
highlight "Systemd neu laden..."
echo
sudo systemctl daemon-reload

# Installiere Oracle Java 21
echo
highlight "Installiere Minecraft... 💀 "
echo
wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb
sudo dpkg -i jdk-21_linux-x64_bin.deb

# Konfiguriere Java-Version
echo
highlight "Konfiguriere Java..."
echo
sudo update-java-alternatives -s /usr/lib/jvm/jdk-21.0.5-oracle-x64/

# Prüfe auf fehlerhafte Dienst
echo
highlight "Prüfe Systemd auf fehlerhafte Dienste..."
echo
sudo systemctl --failed


# Docker neustart
sudo systemctl restart docker.service
sudo systemctl restart docker.socket
echo
highlight Mowoli wird neugestartet 
echo
# X11VNC Restart + Session
sudo systemctl restart x11vnc
# x11vnc -ncache

# Abschlussmeldung
echo
echo -e "\e[32m✔️ Debian-System-Update abgeschlossen! Du hast es an dich geglaubt und es geschafft Tomedo zu Fixen! Das System wird nun neu gestartet.\e[0m"
echo

# Neustart des Systems
sudo reboot
