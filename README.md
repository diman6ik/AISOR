# AISOR
This project allows you to secure an RDP session using SSH session.
AISOR-SERVER transfers the RDP port from a real machine to a virtual machine using nginx(stream).

AiSOR-CLIENT connects the virtual machine to the SSH server and forwards the RDP port locally to your machine.

I have tried to implement compatibility with several Linux distributions including Arch, Debian, Fedora.


The guide is made near-automatic using ip address for Virtualbox virtual machines


## Install Sever on Linux

```
bash <(curl -Ls https://raw.githubusercontent.com/diman6ik/AISOR/refs/heads/main/AISOR-SERVER.sh)
```

## Install Client on Windows
```
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/diman6ik/AISOR/refs/heads/main/AISOR-CLIENT.bat" -OutFile "AISOR-CLIENT.bat"
Start-Process "AISOR-CLIENT.bat"
```
