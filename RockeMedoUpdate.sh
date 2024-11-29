#!/bin/bash

screen

highlight() {
  echo -e "\e[1;33m$1\e[0m"  # Gelb und fett
}


# Setze Skript im Fehlerfall auf Abbruch
set -e

highlight "Starte System-Update für Debian..."

# Stelle sicher, dass 'sl' installiert ist
#if ! command -v sl &> /dev/null; then
#  sudo apt-get install -y sl
#fi

# Starte 'sl' als Ladeanimation
highlight "Loading... 🚂"
#sl

# Entferne alte buster-backports-Einträge und füge sie erneut hinzu
highlight "Konfiguriere die Quellenliste..."
sudo sed -i '/buster-backports/d' /etc/apt/sources.list
echo "deb http://archive.debian.org/debian buster-backports main contrib non-free" | sudo tee -a /etc/apt/sources.list

# Aktualisiere die Paketliste
highlight "Aktualisiere die Paketliste..."
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
highlight Mowoli wird neugestartet 

# Abschlussmeldung
echo -e "\e[32m✔️ Debian-System-Update abgeschlossen! Du hast es an dich gegeglaubt und es geschafft Tomedo zu Fixen! Das System wird nun neu gestartet.\e[0m"

# Neustart des Systems
sudo reboot
