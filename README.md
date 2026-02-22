# Mass commander

Open a terminal, become the root user. Create a directory under the root's home folder called lab_setup, cd into it, and git clone this repository

```
mkdir ~/lab_setup
cd ~/lab_setup
git clone https://github.com/sayoojstherattil/mass-commander.git
```

After cloning, cd into the mass-commander director and check out to testing area for snap:
```
cd mass-commander
```

 Then, just run the lab setup script
```
./lab_setup.sh
```

 Follow the prompts and **make sure that you enter the netcat command** (which it will tell you to enter in the client machines) **in client machines as a user which is in the sudo group**. This can be confirmed by running sudo whoami prior to running the netcat command: 

```
sudo whoami 
```

After everything is set, all client systems will be rebooted and you are fresh to go with the pluser with password `password`, which is a user set up to show the status of the commands ran by the server. 
