
The setup required to make this sample application work, involves
connecting your GR740 board to a Linux machine via Ethernet.
This could mean a direct connection via a cross-over cable,
or a more normal setup involving an Ethernet switch.

Things to do first:

## GR740 board setup

If you check the [GR740 board's user manual](https://www.gaisler.com/doc/gr740/GR-CPCI-GR740-UM.pdf),
you will see that on page 17, Figure 4-8, there's a diagram indicating that the
ETH1 interface is only connected if J22 is connected. Note that connector J22
exists at the bottom side of the PCB - so flip your GR740 over and look at the PCB:
if you see the same picture as that shown in Figure 4-9, **you must move the
configuration plug to the middle location (J22).**

After that, you can power up the board and connect it with the Linux machine via
an Ethernet cable plugged-in **at the bottom right Ethernet jack** (looking at the
board face-front, i.e. with the "GR740" label on the top-right).

## Linux ethernet configuration

On your Linux machine - the one that will run the `binaries/x86_partition` - you
need to make sure that the network configuration mirrors the values input in
the DeploymentView:

    $ grep 192 DeploymentView.aadl
    Deployment::Configuration => "{devname ""eth1"", address ""192.168.0.151"", port 5116 }";
    Deployment::Configuration => "{devname ""greth1"", address ""192.168.0.42"",
      gateway ""192.168.0.1"", netmask ""255.255.255.0"", version ipv4, port 5118 }";
 
Put simply, the default configuration assumes that in your Linux machine, there's
a second Ethernet interface (`eth1`) that has the IP address 192.168.0.151:

    $ sudo ifconfig eth1 192.168.0.151 up

If you use a different configuration, edit this line in the DeploymentView AADL
file and change it to mirror yours. You can change the `eth1` to whatever is 
appropriate for your machine; and you can also change the `192.168.0.151` - but 
you must stay in the 192.168.0.x subnet.

The reason for that is because you can't change the 192.168.0.42 address of the
GR740 side of the Ethernet setup... this address is currently hardcoded in the
PolyORB Ethernet driver.  The PolyORB team is investigating ways to improve
this; in older versions of RTEMS it was possible to modify the IP address after
bootstrapping, but in RTEMS5.1 apparently this is not possible anymore. 

## Build and run

That should do it - you should be able to launch the compiled `x86_partition`
in your Linux machine, and then the `gr740_partition` in your GR740's GRMON;
and see it all work. 
