# Warning

This module is not work in progress and not guranteed to be stable.
Please do not use it at the moment.

# Description

Puppet module to install and configure the software components
relevant to the Digital Repository of Mathematical Formulae project.
# Prerequisites

This role requires a vagrant or labs-vagrant instance.

## Creating a labs-vagrant instance

Add a new instance at

 https://wikitech.wikimedia.org/wiki/Special:NovaInstance
 
 
by clicking [add instance](https://wikitech.wikimedia.org/w/index.php?title=Special:NovaInstance&action=create&project=math&region=eqiad).

Select the version with 2 CPU and assign a name that begins with drmf.

Wait until the instance status is "ACTIVE" and puppet status is "OK".

Now, click on configure and enable the puppet role ``role::labs::vagrant''.

Log into the instance and force a puppet and labs vagrant run via

```
sudo puppet agent -tv
sudo labs-vagrant provision
```
This might take some time. In the meantime you can perform the optional step.

(Optional) Add a web-proxy by visiting the Manage proxies page

  https://wikitech.wikimedia.org/wiki/Special:NovaProxy
  
and clicking on [create proxy](https://wikitech.wikimedia.org/w/index.php?title=Special:NovaProxy&action=create&project=math&region=eqiad)

Now, you are ready to enable the DRMF role. Follow the instructions below.

In case of problebs visit 

https://wikitech.wikimedia.org/wiki/Labs-vagrant

# Installation

Clone (or copy) this repository into your puppet modules/drmf directory:

```bash
git clone https://github.com/DRMF/operations-puppet-drmf modules/drmf
```

Or you could also use a git submodule:

```bash
git submodule add git@github.com:DRMF/operations-puppet-drmf.git modules/drmf
git commit -m 'Adding modules/drmf as a git submodule.'
git submodule init && git submodule update
```

Create a link to to the puppet role:

```bash
ln -s /vagrant/puppet/modules/drmf/manifests/roles/drmf.pp /vagrant/puppet/modules/role/manifests/drmf.pp
```

and enable the newly created drmf role via
```
labs-vagrant enable-role drmf && labs-vagrant provision

```


(PS: The last step with the symbolic link is temporary workaround.)
