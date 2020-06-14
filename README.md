# Minecraft Server

Scripts for installing the requirements for a machine hosting a Minecraft server.

Everything must be ran as root or `sudo`ing.

## Install

Just clone the repository

```bash
git clone https://github.com/srkbz/minecraft-server.git
cd minecraft-server
```

## Configure

The configure script will display a prompt asking for each needed configuration
key. Everything will be stored in `config.env`.

```bash
./configure.sh
```

## Apply

Apply script depends on `config.env` already existing, so make sure it's
already there, wether created manually or with `configure.sh` script.

```
./apply.sh
```
