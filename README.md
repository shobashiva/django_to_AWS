## Dreamify your existing Django app

### Requirements

#### ChefDK

ChefDK includes several utilities for creating and managing chef
resources.  To install it, navigate
[here](https://docs.chef.io/install_dk.html#get-package-run-installer)
and complete the ___Get Package, Run Installer___ and ___Set System
Ruby___ sections.

#### VirtualBox / Vagrant

VirtualBox and Vagrant will provide you with a virtual machine to
provision using this cookbook.  You can download VirtualBox
[here](https://www.virtualbox.org/wiki/Downloads) and Vagrant
[here](https://www.vagrantup.com/downloads.html).

Once those are installed, install a couple of vagrant chef plugins:

```bash
$ vagrant plugin install vagrant-berkshelf
$ vagrant plugin install vagrant-omnibus
```

#### Chef repository

In bitbucket, create a new repository for all your chef files. Name the
repository chef-<your_project_name>

#### Chef-start-up

Into the directory which contains your project, clone this repository.  

Your directory should look as follows:
    $ tree -L 1 .
    .
    |-- chef-start-up
    |-- <project_dir>

Change directories into your project directory, then run the following command

```bash
$ ../chef-start-up/start_django.rb
```

This script will rearrange your folders into the structure they need to be in 
for continuous integration.  It will also create all the recipes you need to 
get your project running on a virtual machine locally, as well as on an AWS
EC2 instance.

It will also create a script for you to create a new virtual machine that will 
run your app.  In your project directory a script named 'start_vm.rb' has been 
added.  To start your virtual machine:

```bash
$ cd /path/to/my/<project_dir>
$ ./start_vm.rb
```
While these recipes will work for most Django apps out of the box, expect to
have to do some debugging related to the dependencies for your particular
project

#### Codeship

Create a new Codeship project for your code.  You can access Codeship 
[here](https://app.codeship.com/apax-software).  To set up a new project you
can follow the tutorial [here](https://documentation.codeship.com/general/account/new-user-signup/).


#### Getting your project set up in AWS

Change directories into your project directory, then run the following command

```bash
$ ../chef-start-up/start_stack.rb
```
This script will create a new AWS OpsWorks stack and app for you, in addition to creating
a new RDS instance for you if you need it.  You can read more about AWS OpsWorks [here](http://docs.aws.amazon.com/opsworks/latest/userguide/workingstacks.html).  You will need to finish some minor setup manually.

Specifically, you will need to complete the setup for the apps in your stack.  You can read 
more about app setup [here](http://docs.aws.amazon.com/opsworks/latest/userguide/workingapps.html).  
You will need to add a valid SSH key to your app.  The key you need is likely uploaded to
Teamwork.

After you finish setting up your app, you will need to add an instance that will run your Django project. You can read 
more about app setup [here](http://docs.aws.amazon.com/opsworks/latest/userguide/workinginstances-add.html).

Finally, you will need to add an EBS layer to your stack.  You can read how to do that [here] (http://docs.aws.amazon.com/opsworks/latest/userguide/layers-elb.html).

#### Codeship revisited

We need to set up Codeship so that when changes are made to the codebase or to the recipes, they
will be pushed to our instance, and our instance will run its deploy step.  This will be accomplished by adding custom scripts to our Codeship deploy stage.  The steps outlined [here](https://documentation.codeship.com/basic/continuous-deployment/deployment-with-custom-scripts/) explain how to deploy via a custom script. You will need to add a deployment pipeline for both the master brach as well as the dev branch.  There is a template for the script in chef-start-up > codeship_scripts > codeship_deploy.txt.  Copy and paste that into your deployment command, taking care to replace <your_stack_id> with either your production stack id or your development stack id.