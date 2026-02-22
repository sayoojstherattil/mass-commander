# Mass commander

Open a terminal and become the root user
```
sudo su - root
```

Create a directory under the root's home folder called lab_setup, cd into it, and git clone this repository

```
mkdir ~/lab_setup
cd ~/lab_setup
git clone https://github.com/sayoojstherattil/mass-commander.git
```

After cloning, cd into the mass-commander director and check out to testing area for snap:
```
cd mass-commander
git checkout testing-area-for-snap
```

 Then, just run the lab setup script
```
./lab_setup.sh
```

 Follow the prompts and **make sure that you enter the netcat command** (which it will tell you to enter in the client machines) **in client machines as a user which is in the sudo group** and is **logged in using X11 as the display server**. This can be confirmed by running sudo whoami prior to running the netcat command: 

```
sudo whoami 
```

Just relogin as the roor user and everything is set, all client systems will be rebooted and you are fresh to go with the pluser with password `password`, which is a user set up to show the status of the commands ran by the server. 

To start mass commander, type `mass_commander` after logging in as the root user

```
mass_commander
```
