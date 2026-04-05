# Lab Automation Software

> [!NOTE]
> A computer in your lab will act as server and others will act as clients; let's call them the `server` and the `clients` respectively. The `Server Side` part is intended the `server` and the `Client Side` is intended for the `clients`.

> [!IMPORTANT]
> Make sure your that all the systems are up to date; apt might throw errors of broken dependencies otherwise
> Always take snapshots before this or any kind of task that deals with root privileges

## Requirements
* `sudo` access to `server` and `clients`
* `clients` runs `X11` (optional)
* `git` installed on `server`

## Installation

### Fresh install

#### Server Side

> [!IMPORTANT]
> Make sure your `server` have a permanent ip

Open a terminal and become the root user
```
sudo su -
```

Create a directory `lab_setup` under the root's home folder, cd into it, and clone this repo
```
mkdir ~/lab_setup
cd ~/lab_setup
git clone https://github.com/sayoojstherattil/mass-commander.git
```

After cloning, cd into the mass-commander directory, run the `lab_setup.sh` script and just follow the prompts:
```
cd mass-commander
./lab_setup.sh
```

#### Client Side

> [!IMPORTANT]
> If you intend the `clients` to show the output in real time inside a terminal window, make sure that you perform the following by logging with `X11` as the display server (this can be selected at the login screen)

> [!TIP]
> It would be easy if you do the installation when students are using the `clients`. You need to run a command in all the `clients` to set up the lab automation software, which would be easy that way.

Ensure that the user you are currently logged in is allowed to use `sudo`. To ensure that, run the following command.
```
sudo whoami 
```
If it return `root`, you are ready to go

Run the netcat command told by the `lab_setup.sh` script which was ran in the `server`
```
nc -lp <port no specified by the script> | bash
```
After all the `clients` finish running the command, inform the server by pressing enter. All the `clients` will reboot when they are done setting up by the `server`.

Relogin as `root` user in the `server` and you are all done!

To see the magic, just run:
```
mass_commander
```

### Expansion installation

To add more `clients` to the existing setup, follow the steps below:

#### Server Side


Open a terminal and become the root user
```
sudo su -
```

cd into the `lab_setup` directory, do a git stash and run the `lab_setup.sh` script
```
cd ~/lab_setup/mass-commander
git stash
./lab_setup.sh
```

say no (`n`) to the asked question and follow the prompts

#### Client Side

> [!IMPORTANT]
> If you intend the new `clients` to show the output in real time inside a terminal window, make sure that you perform the following by logging with `X11` as the display server (this can be selected at the login screen)

> [!TIP]
> It would be easy if you do the expansion when students are using the `clients`. You need to run a command in all the new `clients` to expand the lab automation software, which would be easy that way.

Ensure that the user you are currently logged in is allowed to use `sudo`. To ensure that, run the following command.
```
sudo whoami 
```
If it return `root`, you are ready to go

Run the netcat command told by the `lab_setup.sh` script which was ran in the `server`
```
nc -lp <port no specified by the script> | bash
```
After all the new `clients` finish running the command, inform the server by pressing enter. All the new `clients` will reboot when they are done setting up by the `server`.

You are ready to run the lab automation software on the new `clients` once they have successfully rebooted
