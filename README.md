# Developer Guide for Embedding IOT GUI with Ubuntu Frame

## Introducing Ubuntu Frame

Ubuntu Frame is the foundation for embedded displays. It provides a reliable, secure and easy way to embed your application into a kiosk-style, embedded or digital signage solution. Thanks to snaps and Ubuntu Core, Ubuntu Frame provides all the infrastructure you need to securely deploy and maintain edge devices.

The process of developing an application isn't specific to Ubuntu Frame and nor is the building of custom Ubuntu Core images with "gadget snaps" to configure a system with specific snaps and provide configuration to them. There's plenty of good documentation for this elsewhere.

Developers use different tools and processes to build their graphic applications. So Ubuntu Frame was designed to work with the most popular graphic toolkits used on Linux. To do this, there are several steps to go through and multiple ways to achieve each step. However, the end goal is the same; your graphic application, securely packaged, with all the infrastructure to deploy and configure it.

In this tutorial we will concentrate on the steps specific to deploying your application to work with Ubuntu Frame and Ubuntu Core:

1. Setting up the tools and environment you will need to package and deploy your application
2. taking an application, ensuring it works with Ubuntu Frame on your desktop
3. packaging it as a snap and testing the snap works on your desktop
4. packaging the snap for an IoT device and testing on the device

## Setting up your development environment

Ubuntu Frame provides a tool for developers to simulate how their end application will look and respond in your development environment. So you don’t need to work directly on your target device to do the first design and usability iterations.

For the purpose of this tutorial we assume that you have a Wayland based application that you can test on your desktop. _It is possible to work in a container or on a different computer (if snapd and X forwarding work well enough), or to package X11 based applications to work on Ubuntu Core. But those options are outside the scope of the current tutorial._

The two thing you need to install are Ubuntu Frame and Snapcraft. Both of these are available as snaps:

So open a terminal window and type:

    sudo snap install ubuntu-frame
    sudo snap install snapcraft --classic

If you don't have git installed, now is a good time to install it (on Ubuntu the command is `sudo apt install git`).

## Proving your application works with Ubuntu Frame

The key thing to know about connecting a Wayland app to Ubuntu Frame is that the connection is controlled by the `WAYLAND_DISPLAY` environment variable. We need to set that to the same thing for both processes and, because you may be using a Wayland based desktop environment (which uses the default of `wayland-0`) we'll set it to `wayland-99`.

In a terminal window (that we'll use for this section and the next section) type:

    export WAYLAND_DISPLAY=wayland-99
    ubuntu-frame&

You should see a "Mir on X" window containing a graduated grey background.

You can be using Electron, Flutter, Qt or any other toolkit or programming language to develop your graphic application. So we cannot describe here a sole path for checking all of them. Instead, we are going to use some examples. Now, still in the same terminal window:

### GTK: Mastermind

    sudo apt install gnome-mastermind
    gnome-mastermind

Now Frame's "Mir on X" should contain the "Mastermind" game.

Close that (Ctrl-C) and try the next example...

### Qt: Bomber

    sudo apt install bomber
    QT_QPA_PLATFORM=wayland bomber

Now Frame's "Mir on X" should contain the "Bomber" game. Note that Qt does not default to using Wayland and that `QT_QPA_PLATFORM` needs to be set to get that behaviour.

Close that (Ctrl-C) and try the next example...

### SDL2: Neverputt

    sudo apt install neverputt
    SDL_VIDEODRIVER=wayland neverputt

Now Frame's "Mir on X" should contain the "Neverputt" game. Note that SDL2 does not default to using Wayland and that `SDL_VIDEODRIVER` needs to be set to get that behaviour.

Close that (Ctrl-C) and try the next example...

Actually, that's enough examples. :grin:

You can see how to prove that an application is able to work with Ubuntu Frame. The next step is to use snap packaging to prepare the application for use on an "Internet of Things" device.

## Packaging your application as a Snap

For use with Ubuntu Core your application needs to be packaged as a snap. This will also allow you to leverage over the air updates, automatic rollbacks, delta updates, update semantic channels and more. (If you don't use Ubuntu Core, but instead another form of Linux, we recommend you use snaps to get many of these advantages.)

There's a lot of information about packaging snaps online, and the purpose here is not to teach about the snapcraft packaging tool or the Snap store. There are good resources for that elsewhere online. We instead focus on the things that are special to IoT graphics.

Much of what you find online about packaging GUI applications as a snap refers to packaging for "desktop". Some of that doesn't apply to the "Internet of Things" as Ubuntu Core and Ubuntu Server do not include everything a desktop installation does and the snaps need to run as "daemons" instead of being launched in a user session. In particular, there are various Snapcraft "extensions" that help writing snap recipes that integrate with the Desktop Environment (e.g. using the correct theme).

Writing Snap recipes without these extensions is not difficult as we'll illustrate for each of the example programs.

In the same terminal window you opened at the start of the last section type:

    git clone https://github.com/AlanGriffiths/iot-example-graphical-snap.git
    cd iot-example-graphical-snap

If you look in `snap/snapcraft.yaml` you'll see a generic "snapcraft recipe" for an IoT graphics snap. You don't need to understand this right now, but this is where you will insert instructions for packaging your application.

The customised snapcraft recipe for each example is on a corresponding branch in this repository so continue in the same terminal window:

### GTK: Mastermind

    git checkout GTK3-mastermind
    snapcraft

When you first run `snapcraft` you will be asked "Support for 'multipass' needs to be set up. Would you like to do it now? [y/N]:", answer "yes".

_[Note: some development environments (e.g. containers) do not support multipass, it is possible to use snapcraft with LXD (`snapcraft --use-lxd`), remote building on Launchpad (`snapcraft remote-build`) or running natively `snapcraft --destructive-mode`. The latter will potentially change and, as the name suggests, break the environment it runs in.]_

After a few minutes the snap will be built with a message like:

    Snapped iot-example-graphical-snap_0+git.5fcc9fb_amd64.snap

You can then install and run the snap:

    sudo snap install --dangerous *.snap
    snap run iot-example-graphical-snap

But you are likely to see a warning:

    WARNING: wayland interface not connected! Please run: /snap/iot-example-graphical-snap/current/bin/setup.sh

Run the setup script to connect the missing interfaces, and try again:

    /snap/iot-example-graphical-snap/current/bin/setup.sh
    snap run iot-example-graphical-snap

Now Frame's "Mir on X" should contain the "Mastermind" game.

Close that (Ctrl-C) and try the next example...

### Qt: Bomber

    rm *.snap
    git checkout Qt5-bomber
    snapcraft
    sudo snap install --dangerous *.snap
    snap run iot-example-graphical-snap

Now Frame's "Mir on X" should contain the "Bomber" game.

Close that (Ctrl-C) and try the next example...

### SDL2: Neverputt

    rm *.snap
    git checkout SDL2-neverputt
    snapcraft
    sudo snap install --dangerous *.snap
    snap run iot-example-graphical-snap

Now Frame's "Mir on X" should contain the "Neverputt" game.

Close that (Ctrl-C) and close the Ubuntu Frame window. Your application has been successfully snapped.

## Building for and installing on a device

A lot of devices are not using the "amd64" architecture typical of development machines. The simplest way to build your snap for other architectures is:  

    snapcraft remote-build

This uses the launchpad build farm to build each of the architectures supported by the snap. (This can take some time if the farm is busy, requires you to have a Launchpad account and to be happy uploading your snap source to a public location.)

Once the build is complete you can `scp` the `.snap` file to your device and install using `--dangerous`.

For the sake of these notes I'm using a VM set up using the approach described in [Ubuntu Core: Preparing a virtual machine with graphics support](https://ubuntu.com/tutorials/ubuntu-core-preparing-a-virtual-machine-with-graphics-support). Apart from the address used for scp and ssh this is the same as any other "device". 

    scp -P 10022 *.snap <username>@<hostname>:~
    ssh -p 10022  <username>@<hostname>
    snap install ubuntu-frame
    snap install --dangerous *.snap

You'll see the Ubuntu Frame greyscale background once that install, but (if you've been following the tutorial) you won't see Neverputt start

    $ snap logs -n 30 iot-example-graphical-snap
    ...
    2021-10-28T14:39:20Z iot-example-graphical-snap[6714]: WARNING: hardware-observe interface not connected! Please run: /snap/iot-example-graphical-snap/current/bin/setup.sh
    2021-10-28T14:39:20Z iot-example-graphical-snap[6714]: WARNING: audio-playback interface not connected! Please run: /snap/iot-example-graphical-snap/current/bin/setup.sh
    2021-10-28T14:39:21Z iot-example-graphical-snap[6714]: WARNING: joystick interface not connected! Please run: /snap/iot-example-graphical-snap/current/bin/setup.sh
    2021-10-28T14:39:21Z iot-example-graphical-snap[6714]: ALSA lib conf.c:4120:(snd_config_update_r) Cannot access file /usr/share/alsa/alsa.conf
    2021-10-28T14:39:21Z iot-example-graphical-snap[6714]: Failure to initialize SDL (Could not initialize UDEV)
    ...

All these WARNING message give the clue, connect the missing interfaces and manually start the daemon:

    /snap/iot-example-graphical-snap/current/bin/setup.sh

You should see Neverputt starting.

I've shown all the steps needed to get your snap running on a device.