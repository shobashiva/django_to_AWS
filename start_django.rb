#!/usr/bin/env ruby
require "erb"

def get_input (prompt)
    valid = false
    variable = nil
    while !valid
        puts prompt
        variable = gets.chomp
        if variable == ''
        else
            valid = true
            variable = variable.strip
        end
    end
    return variable
end

## Fetch submodule
system "echo", "-n", "Moving app files to subdirectory ...    "
system "echo", "-n", "\n"

# puts `basename \`git rev-parse --show-toplevel\``
root_repo_name = `basename \`git rev-parse --show-toplevel\``
root_repo_name = root_repo_name.strip
puts root_repo_name

# ######################## Moving files to subdirectory ############################  

cmd = 'rsync -rv --exclude=.git --exclude=.gitignore --exclude=README.md ' + '.' + ' tmp_' + root_repo_name
`#{cmd}`
puts cmd

things_to_delete = `ls -A . | grep -vE 'start-chef|.git*|README|tmp_'`
list_of_things_to_delete = things_to_delete.split(" ")

for item in list_of_things_to_delete do
    cmd = 'rm -rf ' + item
    `#{cmd}`
end

cmd = 'mv tmp_' + root_repo_name + ' ' + root_repo_name
`#{cmd}`

# ######################## CREATING COOKBOOK ############################

system "echo", "-n", "Adding cookbook ...    "
system "echo", "-n", "\n"
system "echo", "-n", "Get ready to answer some questions ...    "
system "echo", "-n", "\n"
cmd = 'yes | berks cookbook ../chef-' + root_repo_name
`#{cmd}`


# ######################## PUSHING COOKBOOK TO REPO ############################

valid_chef_git_repo = false
chef_git_repo = nil

def confirm_repo (cmd)
    begin
        ans = `#{cmd}`
    ensure
        if ans == ''
            return false
        else
            return true
        end
    end
end

while !valid_chef_git_repo do
    puts "Enter full url for chef repo: "
    try_chef_git_repo = gets.chomp
    if try_chef_git_repo == ''
    else
        cmd = 'git ls-remote ' + try_chef_git_repo
        valid_chef_git_repo = confirm_repo(cmd)
        chef_git_repo = try_chef_git_repo.strip
    end
end

chef_repo_name = "chef-" + root_repo_name
cmd = 'git --git-dir=../' + chef_repo_name + '/.git remote add origin ' + chef_git_repo
`#{cmd}`
puts cmd

cmd = 'git --git-dir=../' + chef_repo_name + '/.git  --work-tree=../' + chef_repo_name + ' add .'
`#{cmd}`

cmd = 'git --git-dir=../' + chef_repo_name + '/.git  --work-tree=../' + chef_repo_name + ' commit -m "Initial commit"'
`#{cmd}`

cmd = 'git --git-dir=../' + chef_repo_name + '/.git  --work-tree=../' + chef_repo_name + ' push origin -u master'
`#{cmd}`
puts cmd

# ######################## ADDING COOKBOOK AS SUBMODULE ############################

cmd = 'git --git-dir=../' + root_repo_name + '/.git  --work-tree=../' + root_repo_name + ' submodule add ' + chef_git_repo
`#{cmd}`

# ######################## SETTING UP VAGRANT FILES AND CHEF RECIPES ############################

system "echo", "-n", "Setting up Vagrant run list and chef recipes...    "
system "echo", "-n", "\n"


class ERBContext
  def initialize(hash)
    hash.each_pair do |key, value|
      instance_variable_set('@' + key.to_s, value)
    end
  end

  def get_binding
    binding
  end
end

class String
  def eruby(assigns={})
    ERB.new(self).result(ERBContext.new(assigns).get_binding)
  end
end

cmd = 'rm ../' + chef_repo_name + '/Vagrantfile'
`#{cmd}`
puts cmd

vagrantfile_location = '../' + chef_repo_name + '/Vagrantfile'
virtual_machine_name = 'berkshelf-' + root_repo_name
guest_port = 8000

if !File.exists? vagrantfile_location
    config_data = {
        :config => {
            "VM_NAME" => virtual_machine_name,
            "GUEST_PORT" => guest_port,
            "CHEF_REPO" => chef_repo_name
        }
    }
    system "echo", "-n", "Initializing Vagrantfile with defaults ..."
    template = File.read("../chef-start-up/templates/vagrantfile.erb")
    File.write(vagrantfile_location, template.eruby(config_data))
    sleep(1)
    system "echo", "-e", "\rInitializing Vagrantfile with defaults ... [DONE]\033[K"
end

cmd = 'rm ../' + chef_repo_name + '/recipes/*'
`#{cmd}`
puts cmd

name = get_input("Enter your name: ")

email = get_input("Enter your email: ")

year = get_input("Enter the year: ")

metadata_location = '../' + chef_repo_name + '/metadata.rb'

cmd = 'rm ../' + chef_repo_name + '/metadata.rb'
`#{cmd}`

if !File.exists? metadata_location
    config_data = {
        :config => {
            "NAME" => name,
            "EMAIL" => email,
            "CHEF_REPO" => chef_repo_name
        }
    }
    system "echo", "-n", "Initializing metadata with defaults ..."
    template = File.read("../chef-start-up/templates/metadata.erb")
    File.write(metadata_location, template.eruby(config_data))
    sleep(1)
    system "echo", "-e", "\rInitializing metadata with defaults ... [DONE]\033[K"
end

system_recipe_location = '../' + chef_repo_name + '/recipes/system.rb'

if !File.exists? system_recipe_location
    config_data = {
        :config => {
            "NAME" => name,
            "EMAIL" => email,
            "YEAR" => year,
            "CHEF_REPO" => chef_repo_name
        }
    }
    system "echo", "-n", "Initializing system recipe with defaults ..."
    template = File.read("../chef-start-up/templates/system.erb")
    File.write(system_recipe_location, template.eruby(config_data))
    sleep(1)
    system "echo", "-e", "\rInitializing system recipe with defaults ... [DONE]\033[K"
end

dbname = get_input("Enter a name for your database: ")

data_recipe_location = '../' + chef_repo_name + '/recipes/data.rb'

if !File.exists? data_recipe_location
    config_data = {
        :config => {
            "NAME" => name,
            "EMAIL" => email,
            "YEAR" => year,
            "CHEF_REPO" => chef_repo_name,
            "DB_NAME" => dbname
        }
    }
    system "echo", "-n", "Initializing data recipe with defaults ..."
    template = File.read("../chef-start-up/templates/data.erb")
    File.write(data_recipe_location, template.eruby(config_data))
    sleep(1)
    system "echo", "-e", "\rInitializing data recipe with defaults ... [DONE]\033[K"
end

manage_py = nil
requirements = nil

#TODO: The lines below were meant to grab the files by looking for them, but instead
# it grabs every file a user has that is name 'requirements.txt' or 'manage.py' - which they
# would if they had more than one 

Dir.chdir("../../") do
    manage_py = `find * -name 'manage.py'`
    manage_py = manage_py.strip
    requirements = `find * -name 'requirements.txt'`
    requirements = requirements.strip
end

django_recipe_location = '../' + chef_repo_name + '/recipes/django.rb'

if !File.exists? django_recipe_location
    config_data = {
        :config => {
            "NAME" => name,
            "EMAIL" => email,
            "YEAR" => year,
            "CHEF_REPO" => chef_repo_name,
            "MANAGEPY" => manage_py,
            "REQUIREMENTS" => requirements
        }
    }
    system "echo", "-n", "Initializing django recipe with defaults ..."
    template = File.read("../chef-start-up/templates/django.erb")
    File.write(django_recipe_location, template.eruby(config_data))
    sleep(1)
    system "echo", "-e", "\rInitializing django recipe with defaults ... [DONE]\033[K"
end

settings_file = nil
settings_dist = nil

settings_file = get_input("Enter the path to your settings file, relative to your repository's root folder (it should begin with " + root_repo_name + "/" + root_repo_name + "): ")

settings_dist = get_input("Enter the path to your settings-dist file, relative to your repository's root folder (it should begin with " + root_repo_name + "/" + root_repo_name + " and the file name will be local.py"): ")

code_recipe_location = '../' + chef_repo_name + '/recipes/code.rb'

if !File.exists? code_recipe_location
    config_data = {
        :config => {
            "NAME" => name,
            "EMAIL" => email,
            "YEAR" => year,
            "CHEF_REPO" => chef_repo_name,
            "ROOT_REPO" => root_repo_name,
            "SETTINGS" => settings_file,
            "SETTINGS_DIST" => settings_dist
        }
    }
    system "echo", "-n", "Initializing code recipe with defaults ..."
    template = File.read("../chef-start-up/templates/code.erb")
    File.write(code_recipe_location, template.eruby(config_data))
    sleep(1)
    system "echo", "-e", "\rInitializing code recipe with defaults ... [DONE]\033[K"
end

cmd = 'cp templates/vhost.conf.erb ../' + chef_repo_name + '/templates/default/vhost.conf.erb'
`#{cmd}`
puts cmd

python_version = nil

python_version = get_input("Enter the version of python the project uses (likely python2.7 or python3): ")

server_recipe_location = '../' + chef_repo_name + '/recipes/server.rb'

if !File.exists? server_recipe_location
    config_data = {
        :config => {
            "NAME" => name,
            "EMAIL" => email,
            "YEAR" => year,
            "CHEF_REPO" => chef_repo_name,
            "ROOT_REPO" => root_repo_name,
            "PYTHON" => python_version
        }
    }
    system "echo", "-n", "Initializing server recipe with defaults ..."
    template = File.read("../chef-start-up/templates/server.erb")
    File.write(server_recipe_location, template.eruby(config_data))
    sleep(1)
    system "echo", "-e", "\rInitializing server recipe with defaults ... [DONE]\033[K"
end


######################## CREATING START_VM ############################

start_vm_location = '../start_vm.rb'

if !File.exists? start_vm_location
    config_data = {
        :config => {
            "CHEF_REPO" => chef_repo_name,
            "SETTINGS" => settings_file,
            "SETTINGS_DIST" => settings_dist
        }
    }
    system "echo", "-n", "Initializing start_vm with defaults ..."
    template = File.read("../chef-start-up/templates/start_vm.erb")
    File.write(start_vm_location, template.eruby(config_data))
    sleep(1)
    system "echo", "-e", "\rInitializing start_vm with defaults ... [DONE]\033[K"
end