\# 🚀 WinNetPulse

![Windows](https://img.shields.io/badge/platform-Windows-blue)
![PowerShell](https://img.shields.io/badge/language-PowerShell-darkblue)
![CLI Tool](https://img.shields.io/badge/type-CLI%20Tool-green)


WinNetPulse is a lightweight **Windows network diagnostic CLI tool** written in PowerShell.

It provides fast **Ping and Traceroute diagnostics** with real-time statistics and interactive controls.

Latest Version:1.3

\## Features

![ Demo](Demo.gif)

\- Interactive IP  Domain input

\- Ping or Tracert mode

\- Ping count selection (10  30  50  100  200  Infinite)

\- Infinite mode supports press Q to stop

\- Real-time statistics

\- Timestamp for each result line

&nbsp; - Min latency

&nbsp; - Max latency

&nbsp; - Average latency

&nbsp; - TTL


## Screenshot

![ Example](Example1.png)
![ Example](Example2.png)

## Usage

### 1️⃣ Download

Download `WinNetPulse.ps1` from the **Releases** page.

### 2️⃣ Run the script

Open PowerShell in the folder and run:

```
.\WinNetPulse.ps1
```

If PowerShell blocks the script, you can allow scripts temporarily:

```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### 3️⃣ Enter target

Input the IP address or domain you want to test.

Example:

```
1.1.1.1
google.com
github.com
```

### 4️⃣ Select ping count

Choose one of the preset options:

```
1) 10
2) 30
3) 50
4) 100
5) 200
6) Infinite (-t)
```

Infinite mode can be stopped by pressing **Q**.

### 5️⃣ View results

WinNetPulse will display:

* Latency (colorized)
* Packet loss %
* Min / Max / Avg latency
* TTL
---



\## Installation



Download the latest release from



Releases section



Or clone the repository

git clone https://github.com/zhikai060/WinNetPulse.git



\## Requirements



\- Windows 10 Version 1607 or newer / 11

\- Windows Server 2016 or newer

\- PowerShell 5.1+





\## Roadmap



\- Packet loss %

\- Colorized latency display

\- Multi-target comparison mode

\- Parameter-based CLI execution



---


Made with PowerShell 
