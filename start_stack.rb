#!/usr/bin/env ruby
require "erb"
require "json"

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

def get_tf_input(prompt)
	valid = false
	variable = nil
	while !valid
	    puts prompt
	    if variable == ''
	    else
	        variable = (gets.chomp == 'n') ? false : true
	        valid = true
	    end
	end
	return variable
end

puts `basename \`git rev-parse --show-toplevel\``
root_repo_name = `basename \`git rev-parse --show-toplevel\``
root_repo_name = root_repo_name.strip
 
aws_profile_name = get_input("Enter the name of your preferred profile for aws cli: ")

######################## CREATING RDS INSTANCE ############################

puts "Do you need both a production stack and a production stack, if you don't want both, only a production stack will be created (Y/n):"
dev_stack = (gets.chomp == 'n') ? false : true

puts dev_stack

prod_database_ready = false

if dev_stack
	puts "Do you already have an RDS instance for the development stack (Y/n):"

	dev_database_ready = (gets.chomp == 'n') ? false : true

	if dev_database_ready
		prod_database_endpoint = get_input("Enter endpoint of development RDS instance: ")

		development_database_user = get_input("Enter user for development database: ")

		development_database_password = get_input("Enter password for development database: ")
	else
		development_database_identifier = root_repo_name + '-development'
		development_database_allocated_storage = 10
		development_database_instance_class = 'db.t2.small'
		development_database_engine = 'postgres'

		development_database_master_username = get_input("Enter a master user name for your development database (cannot be ROOT): ")

		development_database_master_user_password = get_input("Enter a password for your master user: ")

		cmd = 'aws rds create-db-instance --db-instance-identifier ' + development_database_identifier + ' --development_database_allocated_storage ' + development_database_allocated_storage + ' --db-instance-class ' + development_database_instance_class + ' --engine ' + development_database_engine + ' --master-username ' + development_database_master_username + ' --master-user-password ' + development_database_master_user_password + ' --profile ' + aws_profile_name
		`#{cmd}`
		puts cmd

puts "Do you already have an RDS instance for the production stack (Y/n):"

prod_database_ready = (gets.chomp == 'n') ? false : true

if prod_database_ready
	prod_database_endpoint = get_input("Enter endpoint of production RDS instance: ")

	production_database_user = get_input("Enter user for production database: ")

	production_database_password = get_input("Enter password for production database: ")
else
	production_database_identifier = root_repo_name + '-production'
	production_database_allocated_storage = 10
	production_database_instance_class = 'db.t2.small'
	production_database_engine = 'postgres'

	production_database_master_username = get_input("Enter a master user name for your production database (cannot be ROOT): ")

	production_database_master_user_password = get_input("Enter a password for your master user: ")

	cmd = 'aws rds create-db-instance --db-instance-identifier ' + production_database_identifier + ' --production_database_allocated_storage ' + production_database_allocated_storage + ' --db-instance-class ' + production_database_instance_class + ' --engine ' + production_database_engine + ' --master-username ' + production_database_master_username + ' --master-user-password ' + production_database_master_user_password + ' --profile ' + aws_profile_name
	puts cmd


######################## CREATING NEW STACK ############################

# getting service role arn

cmd = 'aws iam get-role --role-name aws-opsworks-service-role --profile ' + aws_profile_name
service_role = `#{cmd}`
service_role = JSON.parse(service_role)
service_role_arn = service_role['Role']['Arn']


# getting default instance profile arn

cmd = 'aws iam get-instance-profile --instance-profile-name aws-opsworks-ec2-role --profile ' + aws_profile_name
ec2_role = `#{cmd}`
ec2_role = JSON.parse(ec2_role)
ec2_role_arn = ec2_role['InstanceProfile']['Arn']

cmd = 'aws configure get region --profile ' + aws_profile_name
region = `#{cmd}` 
region = region.strip

cmd = 'aws configure get aws_access_key_id --profile ' + aws_profile_name
aws_access_key_id = `#{cmd}` 
aws_access_key_id = aws_access_key_id.strip

cmd = 'aws configure get aws_secret_access_key --profile ' + aws_profile_name
aws_secret_access_key = `#{cmd}` 
aws_secret_access_key = aws_secret_access_key.strip

cookbook_dest = get_input("Enter a valid destination (s3 bucket) for your custom cookbooks (include trailing slash): ")

configure_chef = "Name=Chef,Version=12"

if dev_stack
	cookbook_dest = cookbook_dest + root_repo_name + '-dev.zip'
	custom_cookbook = "Type=s3,Url=" + cookbook_dest + ",Username=" + aws_access_key_id + ",Password=" + aws_secret_access_key

	cmd = 'aws opsworks create-stack --name ' + root_repo_name + '-dev ' + '--service-role-arn ' + service_role_arn + ' --default-instance-profile-arn ' + ec2_role_arn + ' --stack-region ' + region + ' --use-custom-cookbooks --use-opsworks-security-groups ' + ' --custom-cookbook ' + custom_cookbook + ' --default-os "Ubuntu 14.04 LTS"' + ' --configuration-manager ' + configure_chef + ' --profile ' + aws_profile_name
	dev_stack_info = `#{cmd}`
	dev_stack_info = JSON.parse(stack_info)
	dev_stack_id = stack_info['StackId']
	puts dev_stack_id


######################## CREATING NEW LAYER ############################

cmd = "aws opsworks create-layer --stack-id " + dev_stack_id + ' --name "App Server" --shortname app_server --type custom --profile ' + aws_profile_name
if dry_run
	puts cmd
else
	layer_info = `#{cmd}`
	layer_info = JSON.parse(layer_info)
	layer_id = layer_info['LayerId']
	puts layer_id
end

recipe_prefix = 'chef-' + root_repo_name + '-dev'

add_custom_recipes = {
	:Setup => [recipe_prefix + "::system",recipe_prefix + "::server"],
	:Deploy => [recipe_prefix + "::code",recipe_prefix + "::django"]
}

add_custom_recipes = JSON.generate(add_custom_recipes, quirks_mode: true)
add_custom_recipes = JSON.generate(add_custom_recipes, quirks_mode:true)
# add_custom_recipes = [add_custom_recipes].to_json


######################## ADDING RECIPES ############################
cmd = "aws opsworks update-layer --layer-id " + layer_id + " --custom-recipes " + add_custom_recipes + ' --profile ' + aws_profile_name 
if dry_run
	puts cmd
else
	`#{cmd}`
	puts cmd
end

######################## CREATING NEW APP ############################

cmd = "git config --get remote.origin.url"
git_url = `#{cmd}`
git_url = git_url.strip

revision = "dev"
# create app

app_source = "Type=git,Url=" + git_url + "," + "Revision=" + revision
# you will need to add the SSH key manually

# there is a chance the database isn't created yet, so keep trying until we get it
endpoint = false

while !endpoint
	cmd = 'aws rds describe-db-instances --db-instance-identifier ' + development_database_identifier + ' --profile ' + aws_profile_name
	endpoint = `#{cmd}`
	endpoint = JSON.parse(endpoint)
	development_db_url = endpoint["DBInstances"][0]["Endpoint"]["Address"]
	if development_db_url == ''
	else
		endpoint = true
	end
end

	environment_variable = [
		{
			:Key=>"AWS_ACCESS_KEY_ID",
			:Value=>aws_access_key_id,
			:Secure=>false
		},
		{
			:Key=>"AWS_SECRET_ACCESS_KEY",
			:Value=>aws_secret_access_key,
			:Secure=>true
		},
		{
			:Key=>"DATABASE_NAME",
			:Value=>development_database_name,
			:Secure=>false
		},
		{
			:Key=>"DATABASE_HOST",
			:Value=>development_db_url,
			:Secure=>false
		},
		{
			:Key=>"DATABASE_USER",
			:Value=>development_database_user,
			:Secure=>false
		},
		{
			:Key=>"DATABASE_PASSWORD",
			:Value=>development_database_password,
			:Secure=>true
		}
	]

	environment_variable = JSON.generate(environment_variable, quirks_mode: true)
	environment_variable = JSON.generate(environment_variable, quirks_mode:true)

	puts environment_variable

	cmd = 'aws opsworks create-app --stack-id ' + dev_stack_id + ' --name ' + root_repo_name + ' --type other' + ' --app-source '+ app_source + ' --environment ' + environment_variable + ' --profile ' + aws_profile_name 
	if dry_run
		puts cmd
	else
		`#{cmd}`
		puts cmd
	end
end


cookbook_dest = cookbook_dest + root_repo_name + '.zip'
custom_cookbook = "Type=s3,Url=" + cookbook_dest + ",Username=" + aws_access_key_id + ",Password=" + aws_secret_access_key

cmd = 'aws opsworks create-stack --name ' + root_repo_name + ' ' + '--service-role-arn ' + service_role_arn + ' --default-instance-profile-arn ' + ec2_role_arn + ' --stack-region ' + region + ' --use-custom-cookbooks --use-opsworks-security-groups ' + ' --custom-cookbook ' + custom_cookbook + ' --default-os "Ubuntu 14.04 LTS"' + ' --configuration-manager ' + configure_chef + ' --profile ' + aws_profile_name
if dry_run
	puts cmd
else
	prod_stack_info = `#{cmd}`
	prod_stack_info = JSON.parse(prod_stack_info)
	prod_stack_id = prod_stack_info['StackId']
	puts prod_stack_id
end


######################## CREATING NEW LAYER FOR PRODUCTION ############################

cmd = "aws opsworks create-layer --stack-id " + prod_stack_id + ' --name "App Server" --shortname app_server --type custom --profile ' + aws_profile_name
if dry_run
	puts cmd
else
	layer_info = `#{cmd}`
	layer_info = JSON.parse(layer_info)
	layer_id = layer_info['layerId']
	puts layer_id
end

recipe_prefix = 'chef-' + root_repo_name

add_custom_recipes = {
	:Setup => [recipe_prefix + "::system",recipe_prefix + "::server"],
	:Deploy => [recipe_prefix + "::code",recipe_prefix + "::django"]
}

add_custom_recipes = JSON.generate(add_custom_recipes, quirks_mode: true)
add_custom_recipes = JSON.generate(add_custom_recipes, quirks_mode:true)
# add_custom_recipes = [add_custom_recipes].to_json

######################## ADDING RECIPES ############################

cmd = "aws opsworks update-layer --layer-id " + layer_id + " --custom-recipes " + add_custom_recipes + ' --profile ' + aws_profile_name 
if dry_run
	puts cmd
else
	`#{cmd}`
	puts cmd
end

######################## CREATING NEW APP ############################

cmd = "git config --get remote.origin.url"
git_url = `#{cmd}`
git_url = git_url.strip

revision = "master"
# create app
app_source = "Type=git," + git_url + "," + "Revision=" + revision

# there is a chance the database isn't created yet, so keep trying until we get it
endpoint = false

while !endpoint
	cmd = 'aws rds describe-db-instances --db-instance-identifier ' + production_database_identifier + ' --profile ' + aws_profile_name
	endpoint = `#{cmd}`
	endpoint = JSON.parse(endpoint)
	production_db_url = endpoint["DBInstances"][0]["Endpoint"]["Address"]
	if production_db_url == ''
	else
		endpoint = true
	end
end

environment_variable = [
	{
		:Key=>"AWS_ACCESS_KEY_ID",
		:Value=>aws_access_key_id,
		:Secure=>false
	},
	{
		:Key=>"AWS_SECRET_ACCESS_KEY",
		:Value=>aws_secret_access_key,
		:Secure=>true
	},
	{
		:Key=>"DATABASE_NAME",
		:Value=>production_database_name,
		:Secure=>false
	},
	{
		:Key=>"DATABASE_HOST",
		:Value=>production_db_url,
		:Secure=>false
	},
	{
		:Key=>"DATABASE_USER",
		:Value=>production_database_user,
		:Secure=>false
	},
	{
		:Key=>"DATABASE_PASSWORD",
		:Value=>development_database_password,
		:Secure=>true
	}
]

environment_variable = JSON.generate(environment_variable, quirks_mode: true)
environment_variable = JSON.generate(environment_variable, quirks_mode:true)

puts environment_variable

cmd = 'aws opsworks create-app --stack-id ' + prod_stack_id + ' --name ' + root_repo_name + ' --type other' + ' --app-source '+ app_source + ' --environment ' + environment_variable + ' --profile ' + aws_profile_name 
if dry_run
	puts cmd
else
	`#{cmd}`
	puts cmd
end