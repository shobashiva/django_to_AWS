#!/usr/bin/env ruby
require "erb"
require "json"

# dry_run = ARGV[0]

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

# puts `basename \`git rev-parse --show-toplevel\``
root_repo_name = `basename \`git rev-parse --show-toplevel\``
root_repo_name = root_repo_name.strip

aws_profile_name = 'jason-mize' 
# aws_profile_name = get_input("Enter the name of your preferred profile for aws cli: ")

# ######################## CREATING RDS INSTANCE ############################

# dev_stack = get_tf_input("Do you need both a production stack and a production stack, if you don't want both, only a production stack will be created (Y/n): ")

# puts dev_stack

# prod_database_ready = false

dev_stack = true
dry_run = false
# if dev_stack
# 	dev_database_ready = get_tf_input("Do you already have an RDS instance for the development stack (Y/n): ")

# 	if dev_database_ready
# 		prod_database_endpoint = get_input("Enter endpoint of development RDS instance: ")

# 		development_database_user = get_input("Enter user for development database: ")

# 		development_database_password = get_input("Enter password for development database: ")

# 		development_database_name = get_input("Enter name for development database: ")
# 	else
development_database_identifier = root_repo_name + '-development'
development_database_identifier.gsub!(/_/, '-')


		# development_database_identifier = root_repo_name + '-development'
		# development_database_identifier.gsub!(/_/, '-')
# 		development_database_allocated_storage = '10'
# 		development_database_instance_class = 'db.t2.small'
# 		development_database_engine = 'postgres'

# 		development_database_master_username = get_input("Enter a master user name for your development database (cannot be ROOT): ")

# 		development_database_master_user_password = get_input("Enter a password for your master user (must be greater than 8 charaters): ")

# 		development_database_name = get_input("Enter name for development database: ")

# 		cmd = 'aws rds create-db-instance --db-instance-identifier ' + development_database_identifier + ' --allocated-storage ' + development_database_allocated_storage + ' --db-instance-class ' + development_database_instance_class + ' --engine ' + development_database_engine + ' --master-username ' + development_database_master_username + ' --master-user-password ' + development_database_master_user_password + ' --db-name ' + development_database_name + ' --profile ' + aws_profile_name
# 		if dry_run
# 			puts cmd
# 		else
# 			`#{cmd}`
# 			puts cmd
# 		end
# 	end
# end

# prod_database_ready = get_tf_input("Do you already have an RDS instance for the production stack (Y/n): ")

# if prod_database_ready
# 	prod_database_endpoint = get_input("Enter endpoint of production RDS instance: ")

# 	production_database_user = get_input("Enter user for production database: ")

# 	production_database_password = get_input("Enter password for production database (must be greater than 8 charaters): ")

# 	production_database_name = get_input("Enter name for production database: ")
# else
# 	production_database_identifier = root_repo_name + '-production'
# 	production_database_identifier.gsub!(/_/, '-')
# 	production_database_allocated_storage = '10'
# 	production_database_instance_class = 'db.t2.small'
# 	production_database_engine = 'postgres'

# 	production_database_master_username = get_input("Enter a master user name for your production database (cannot be ROOT): ")

development_database_name = 'ecumenical'
development_database_user = 'ecumenical'
development_database_password = '$ecH_!dk~j=G6LtJ'

# 	production_database_master_user_password = get_input("Enter a password for your master user: ")

# 	production_database_name = get_input("Enter name for production database: ")

# 	cmd = 'aws rds create-db-instance --db-instance-identifier ' + production_database_identifier + ' --allocated-storage ' + production_database_allocated_storage + ' --db-instance-class ' + production_database_instance_class + ' --engine ' + production_database_engine + ' --master-username ' + production_database_master_username + ' --master-user-password ' + production_database_master_user_password + ' --profile ' + aws_profile_name
# 	if dry_run
# 		puts cmd
# 	else
# 		`#{cmd}`
# 		puts cmd
# 	end
# end

######################## CREATING NEW STACK ############################

# getting service role arn

# cmd = 'aws iam get-role --role-name aws-opsworks-service-role --profile ' + aws_profile_name
# service_role = `#{cmd}`
# service_role = JSON.parse(service_role)
# service_role_arn = service_role['Role']['Arn']


# # getting default instance profile arn

# cmd = 'aws iam get-instance-profile --instance-profile-name aws-opsworks-ec2-role --profile ' + aws_profile_name
# ec2_role = `#{cmd}`
# ec2_role = JSON.parse(ec2_role)
# ec2_role_arn = ec2_role['InstanceProfile']['Arn']

cmd = 'aws configure get region --profile ' + aws_profile_name
region = `#{cmd}` 
region = region.strip

cmd = 'aws configure get aws_access_key_id --profile ' + aws_profile_name
aws_access_key_id = `#{cmd}` 
aws_access_key_id = aws_access_key_id.strip

cmd = 'aws configure get aws_secret_access_key --profile ' + aws_profile_name
aws_secret_access_key = `#{cmd}` 
aws_secret_access_key = aws_secret_access_key.strip

# cookbook_dest = get_input("Enter a valid destination (s3 bucket) for your custom cookbooks (include trailing slash): ")

# configure_chef = "Name=Chef,Version=12"

if dev_stack
	# cookbook_dest = cookbook_dest + root_repo_name + '-dev.zip'
# 	custom_cookbook = "Type=s3,Url=" + cookbook_dest + ",Username=" + aws_access_key_id + ",Password=" + aws_secret_access_key

# 	cmd = 'aws opsworks create-stack --name ' + root_repo_name + '-dev ' + '--service-role-arn ' + service_role_arn + ' --default-instance-profile-arn ' + ec2_role_arn + ' --stack-region ' + region + ' --use-custom-cookbooks --use-opsworks-security-groups ' + ' --custom-cookbook ' + custom_cookbook + ' --default-os "Ubuntu 14.04 LTS"' + ' --configuration-manager ' + configure_chef + ' --profile ' + aws_profile_name
# 	if dry_run
# 		puts cmd
# 	else
# 		dev_stack_info = `#{cmd}`
# 		dev_stack_info = JSON.parse(dev_stack_info)
# 		dev_stack_id = dev_stack_info['StackId']
# 		puts dev_stack_id
# 	end
	
	dev_stack_id = '3ffe4201-0e7f-4840-a8c2-b2364c417c67'

######################## CREATING NEW LAYER ############################

	# cmd = "aws opsworks create-layer --stack-id " + dev_stack_id + ' --name "App Server" --shortname app_server --type custom --profile ' + aws_profile_name
	# if dry_run
	# 	puts cmd
	# else
	# 	layer_info = `#{cmd}`
	# 	layer_info = JSON.parse(layer_info)
	# 	layer_id = layer_info['LayerId']
	# 	puts layer_id
	# end

	layer_id = '338e2aa5-c047-4a2c-9f97-118040f1a605'

	recipe_prefix = root_repo_name + '-dev'

	add_custom_recipes = {
		:Setup => [recipe_prefix + "::system",recipe_prefix + "::server"],
		:Deploy => [recipe_prefix + "::code",recipe_prefix + "::django"]
	}

	add_custom_recipes = JSON.generate(add_custom_recipes, quirks_mode: true)
	add_custom_recipes = JSON.generate(add_custom_recipes, quirks_mode:true)
	# add_custom_recipes = [add_custom_recipes].to_json


	######################## ADDING RECIPES ############################
	# cmd = "aws opsworks update-layer --layer-id " + layer_id + " --custom-recipes " + add_custom_recipes + ' --profile ' + aws_profile_name 
	# if dry_run
	# 	puts cmd
	# else
	# 	`#{cmd}`
	# 	puts cmd
	# end

	######################## CREATING NEW APP ############################

	cmd = "git config --get remote.origin.url"
	git_url = `#{cmd}`
	git_url = git_url.strip

	# ssh_key = '-----BEGIN RSA PRIVATE KEY-----MIIEpQIBAAKCAQEAznvqEmD/TnLjRzmAVSQGKNKmyBcc+Sz4r69rMT4Ka5w8NRqFtK8kiDCkBwmX7sj8dUv/ZVrH3yQcexJ2RYfo0KsNinM9OJUq8nGpjLTXsNPVnXhyV6N5zilphWbheD9rUeTTge+lHqNHvqUi4Zv+L85dCloU2vVG7m8oZeVFQAIKlbLwxkJ2yuIKcctV7jBC1PPl4xmHtAkmw6X1ASzJoXTRJFGlAjdtjS68grHhFOfmWqCf7d0VTpbTBAW2cjzK+CkGvvO/JiLhhRiWmqxUhOHVcNSUIaa5CQ6+ZymI1prteuRw0IS4/FkIDut/WYkR+8mtX1UPuF1PqKyyzqVczQIDAQABAoIBAQC/LZ3ozGQ2N0tV29iFfCgzze5b3oKV9tx+lbVyz1WIkwxvwpG/XFY/voFwfqJslSyiUe4y4p2ibeXs0YguEosuAOI1qUMqy3oLJc/tFleKQmhLN4Tuvc5+Yntv53SlCFsOZQasDL1eI6G+01j7eJodmz0r44HhxS2af9LwnRnECzXqDvupfI6Zr3NvH+4xAa6N0AMHL3Vi1HahHpbNpR515ccyN3EKe1zBdGfc9O4ApZD8pvbw5/oaxc2JImK9JGVcjnLWU3KMKPJHo/z9NbjHG4IeC52OJWpSD7CPL4NODg8wC1gpSh+w3qynFRm5J2f7cc7l9e5FUXqQlvTMIEHBAoGBAOwX4RxtMN8OPV8d0iqgRq+LpW1k8JgpV3zuAhg1Dvoq9HnK2qvOBXm3mqY5lKPPCoBxd3qtvCVXhSAOwg2yXIdT1bJge5lBcLHLVaXV581sSTleHvlpRlmY3cmgJl6rOxL3IqCixiH55z7KL8a4sMHVdYdQ7JaJeIODyXrTYpUdAoGBAN/k6eZNOsCNzwspoohBg3ZfOtlhKUQ/glviHVExM8Com8SdiMwcxAgbY2dQDQ5EeF59IIHCZYy2OHCrrZ0dn8ez62C8UoDLwG6PTiqgR4m4kWpa3vfnkcdU2BlMAmYm1ECr1ah8ARntTUpSd4gVlP7RZgGDUK6QbHLuMx+ZmMdxAoGBAIgqRZUFjNg4+EBxjJM1GU+JtQFg5Dp+LY1KID8h6t9yAspzqqbIDfRjZnhUYVwQvzfROV2x8f9/eLJCkL0hj6glO+zDJMYBLiP86ArbUfPyblD97dNfWkm2lsQA7+BN1aZcjsYi2y8hWLOoHOH6B0fj+wLuM2WnJ7CCQ6PpYsQpAoGAAMhG/PQGIYgdUheqJrm74N0CUqIhR8jFBtcqbQ8z9Bdiu/Qk9zmegby+wyynbwZUOVhMlcd9HVnBprsi1yq0VTlOuD7QNvz/RiOgDUwUE+oeL/XzU4BupPip7KS0WXEHStaO35DXXCTVIU5adpJEvAM1TQoNbR66Eki8yv55ZzECgYEA5VgnJ5OvkertyyszmXQZOcBTZEOfWgx7pOQOtSKp7hS3HcDq4mjqEIxBsf2rXy8hOv9dEDrolEslrFTTiwyFGeyorKUzcSfgOy/HoYuHn5yBQI2BmESeKesFPzCgwXxPh58nkX7PWxbby1B4zMUwS6jsoIIqf0A7ShcbRUw7rN0=-----END RSA PRIVATE KEY-----'

	# ssh_key = '-----BEGIN RSA PRIVATE KEY-----
	# MIIEpAIBAAKCAQEAswjO85QLFufrWFn6q9x9VYxNXmiM+T6qoPUlmzkgsjlkzTj6
	# hZdbPxTZGZmD6RlWKkNq7vlEo4ObYmr8/VaQ2v9Ou5z3uduEFFI/xbBBCL5Gc+u7
	# 964TRMjrBqGsYLFzCmSqtMBv2Mx4CbQu2rWHoi44FvAcAOYwsAbB2vC/QY/Z5Ps8
	# hi17XhATEwmliJStsl35Cm+UzqlCUdX/qQQwUVjyyA3ouODVMG7ghTimcBARi4fN
	# rwIM0jTIHRXBeYug98M7ztnpMLjIymjKz6VmQAmUTj7JITGrLm5Jd+nkDtLRF7TQ
	# X7KvJb63Jj3tRbJi3q5/tQieLFx1VkHUohLJWwIDAQABAoIBAQCDDCiHzM6NNrdi
	# 1YIR+HPZgbhEKZ0+9+rnpGmhhCB1tGMfgNyHmrGUrAr5nRAcOIqEpxKH1/exBK1h
	# TdTfD1U6p/SWiaAe8Bpu0YGSj6Aa6UQip+PPuSCrkbHPCdpmcJ03d1Yotk9oTspy
	# t+wv9P5R7SjrSVgGJHhw8JFHVD96mbmUOUQNEQknTpfIVox/3NS+abnQhziMIRJ2
	# zpXSXJS1wZJmcFx3PEzUlXkPkc8oPPmWF75dRxbiTmfeYqlUW06Xjfpd9GogyX2c
	# f49SbOu4bxJaRApCMvp7vumlzLiXBuMS+Lje8CPlXUbp4/y2ws6CvywHd9b/4gxn
	# 2oDbPIl5AoGBAOmt1eHwQFYWIta3roRAgJbqiNjPXp0hu/sZZgE3Bb1E0DCqizbQ
	# /QMwsHVYE6UzCFR+qxvEcdBIS/809oESLP+tthONrkoQF0yzh7o4JZOtNJA0URDp
	# WEdpU00PfZxXebxkJSIqb+pFtmseoMjazwu5CCgDLydapUrjpFD91fO3AoGBAMQi
	# vr213tpoQGfRcmdSWX42YzHMHRzzETja50M72jgZfApYdD56bX4SUvgOT4RunInk
	# xajzYz47zqf0YJgKZ0aJWGMZ5P3nVY80eYwXKhsiAfjp/7YwYc9RrcxDVPkrM7wv
	# R53Q4qyui6u+zsY75ZoG9f9JMInKydOCqE/G5X99AoGBAJnvLcocngUXp/OSJKBy
	# bUL9VRCd6lHQeyi6XnvGZz17Kzoj3nlJyqJjXJqwXqCgsYgXuVgdXGw8c/O2S/xS
	# oNn88MiIuJuJZg/c5DhD7F0P6GRmUlC1prXEKF/HKJPo/ASiY+PR2M+XBMgj8P7f
	# RS0PwtO45UMjb2eZ9hB0ZpCZAoGAYpiYzCNOCPsZTVczrI7wIAtVKCZUiEYEZVFd
	# qiW/WC4vdb/rh7Dhs9ugS8Rd4tP76zHOz1SykglcpH+rwyKPshy/Cupse9q73wZh
	# B7RpXURmO2veOQbvVFnaBXHfmHZIRpR56vKj0GzaF5cOuQZJMHnJVfDD7rC7bpEi
	# 7R+uJL0CgYB4pf1FaFWqeDiluXIR9RQ6UfCu8AT9i9vsTDDPtrE2teXAG5jpIdzr
	# rigpUO9p9KkZgSC5xVE4uVXfoNPU0halXUUyu7Vaztj0sPSawbiuzt8WNJBdwGpk
	# aCDXLyrLGc7LSiz1lcQSsojCER12CbUUP2ex2DzWa6Kc1UX55y0e0w==
	# -----END RSA PRIVATE KEY-----'
	# ssh_key = 'MIIEpQIBAAKCAQEAznvqEmD/TnLjRzmAVSQGKNKmyBcc+Sz4r69rMT4Ka5w8NRqFtK8kiDCkBwmX7sj8dUv/ZVrH3yQcexJ2RYfo0KsNinM9OJUq8nGpjLTXsNPVnXhyV6N5zilphWbheD9rUeTTge+lHqNHvqUi4Zv+L85dCloU2vVG7m8oZeVFQAIKlbLwxkJ2yuIKcctV7jBC1PPl4xmHtAkmw6X1ASzJoXTRJFGlAjdtjS68grHhFOfmWqCf7d0VTpbTBAW2cjzK+CkGvvO/JiLhhRiWmqxUhOHVcNSUIaa5CQ6+ZymI1prteuRw0IS4/FkIDut/WYkR+8mtX1UPuF1PqKyyzqVczQIDAQABAoIBAQC/LZ3ozGQ2N0tV29iFfCgzze5b3oKV9tx+lbVyz1WIkwxvwpG/XFY/voFwfqJslSyiUe4y4p2ibeXs0YguEosuAOI1qUMqy3oLJc/tFleKQmhLN4Tuvc5+Yntv53SlCFsOZQasDL1eI6G+01j7eJodmz0r44HhxS2af9LwnRnECzXqDvupfI6Zr3NvH+4xAa6N0AMHL3Vi1HahHpbNpR515ccyN3EKe1zBdGfc9O4ApZD8pvbw5/oaxc2JImK9JGVcjnLWU3KMKPJHo/z9NbjHG4IeC52OJWpSD7CPL4NODg8wC1gpSh+w3qynFRm5J2f7cc7l9e5FUXqQlvTMIEHBAoGBAOwX4RxtMN8OPV8d0iqgRq+LpW1k8JgpV3zuAhg1Dvoq9HnK2qvOBXm3mqY5lKPPCoBxd3qtvCVXhSAOwg2yXIdT1bJge5lBcLHLVaXV581sSTleHvlpRlmY3cmgJl6rOxL3IqCixiH55z7KL8a4sMHVdYdQ7JaJeIODyXrTYpUdAoGBAN/k6eZNOsCNzwspoohBg3ZfOtlhKUQ/glviHVExM8Com8SdiMwcxAgbY2dQDQ5EeF59IIHCZYy2OHCrrZ0dn8ez62C8UoDLwG6PTiqgR4m4kWpa3vfnkcdU2BlMAmYm1ECr1ah8ARntTUpSd4gVlP7RZgGDUK6QbHLuMx+ZmMdxAoGBAIgqRZUFjNg4+EBxjJM1GU+JtQFg5Dp+LY1KID8h6t9yAspzqqbIDfRjZnhUYVwQvzfROV2x8f9/eLJCkL0hj6glO+zDJMYBLiP86ArbUfPyblD97dNfWkm2lsQA7+BN1aZcjsYi2y8hWLOoHOH6B0fj+wLuM2WnJ7CCQ6PpYsQpAoGAAMhG/PQGIYgdUheqJrm74N0CUqIhR8jFBtcqbQ8z9Bdiu/Qk9zmegby+wyynbwZUOVhMlcd9HVnBprsi1yq0VTlOuD7QNvz/RiOgDUwUE+oeL/XzU4BupPip7KS0WXEHStaO35DXXCTVIU5adpJEvAM1TQoNbR66Eki8yv55ZzECgYEA5VgnJ5OvkertyyszmXQZOcBTZEOfWgx7pOQOtSKp7hS3HcDq4mjqEIxBsf2rXy8hOv9dEDrolEslrFTTiwyFGeyorKUzcSfgOy/HoYuHn5yBQI2BmESeKesFPzCgwXxPh58nkX7PWxbby1B4zMUwS6jsoIIqf0A7ShcbRUw7rN0='
	# ssh_key = 'MIIEpQIBAAKCAQEAznvqEmD/TnLjRzmAVSQGKNKmyBcc+Sz4r69rMT4Ka5w8NRqFtK8kiDCkBwmX7sj8dUv/ZVrH3yQcexJ2RYfo0KsNinM9OJUq8nGpjLTXsNPVnXhyV6N5zilphWbheD9rUeTTge+lHqNHvqUi4Zv+L85dCloU2vVG7m8oZeVFQAIKlbLwxkJ2yuIKcctV7jBC1PPl4xmHtAkmw6X1ASzJoXTRJFGlAjdtjS68grHhFOfmWqCf7d0VTpbTBAW2cjzK+CkGvvO/JiLhhRiWmqxUhOHVcNSUIaa5CQ6+ZymI1prteuRw0IS4/FkIDut/WYkR+8mtX1UPuF1PqKyyzqVczQIDAQABAoIBAQC/LZ3ozGQ2N0tV29iFfCgzze5b3oKV9tx+lbVyz1WIkwxvwpG/XFY/voFwfqJslSyiUe4y4p2ibeXs0YguEosuAOI1qUMqy3oLJc/tFleKQmhLN4Tuvc5+Yntv53SlCFsOZQasDL1eI6G+01j7eJodmz0r44HhxS2af9LwnRnECzXqDvupfI6Zr3NvH+4xAa6N0AMHL3Vi1HahHpbNpR515ccyN3EKe1zBdGfc9O4ApZD8pvbw5/oaxc2JImK9JGVcjnLWU3KMKPJHo/z9NbjHG4IeC52OJWpSD7CPL4NODg8wC1gpSh+w3qynFRm5J2f7cc7l9e5FUXqQlvTMIEHBAoGBAOwX4RxtMN8OPV8d0iqgRq+LpW1k8JgpV3zuAhg1Dvoq9HnK2qvOBXm3mqY5lKPPCoBxd3qtvCVXhSAOwg2yXIdT1bJge5lBcLHLVaXV581sSTleHvlpRlmY3cmgJl6rOxL3IqCixiH55z7KL8a4sMHVdYdQ7JaJeIODyXrTYpUdAoGBAN/k6eZNOsCNzwspoohBg3ZfOtlhKUQ/glviHVExM8Com8SdiMwcxAgbY2dQDQ5EeF59IIHCZYy2OHCrrZ0dn8ez62C8UoDLwG6PTiqgR4m4kWpa3vfnkcdU2BlMAmYm1ECr1ah8ARntTUpSd4gVlP7RZgGDUK6QbHLuMx+ZmMdxAoGBAIgqRZUFjNg4+EBxjJM1GU+JtQFg5Dp+LY1KID8h6t9yAspzqqbIDfRjZnhUYVwQvzfROV2x8f9/eLJCkL0hj6glO+zDJMYBLiP86ArbUfPyblD97dNfWkm2lsQA7+BN1aZcjsYi2y8hWLOoHOH6B0fj+wLuM2WnJ7CCQ6PpYsQpAoGAAMhG/PQGIYgdUheqJrm74N0CUqIhR8jFBtcqbQ8z9Bdiu/Qk9zmegby+wyynbwZUOVhMlcd9HVnBprsi1yq0VTlOuD7QNvz/RiOgDUwUE+oeL/XzU4BupPip7KS0WXEHStaO35DXXCTVIU5adpJEvAM1TQoNbR66Eki8yv55ZzECgYEA5VgnJ5OvkertyyszmXQZOcBTZEOfWgx7pOQOtSKp7hS3HcDq4mjqEIxBsf2rXy8hOv9dEDrolEslrFTTiwyFGeyorKUzcSfgOy/HoYuHn5yBQI2BmESeKesFPzCgwXxPh58nkX7PWxbby1B4zMUwS6jsoIIqf0A7ShcbRUw7rN0='
	# ssh_key = get_input("Enter the ssh key to access the git repo for your app: ")
	revision = "dev"
	# create app
	
	# app_source = "Type=git,Url=" + git_url + ",SshKey=" + ssh_key + "Revision=" + revision
	app_source = "Type=git,Url=" + git_url + "Revision=" + revision


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

	cmd = 'aws opsworks create-app --stack-id ' + dev_stack_id + ' --name tesrt_er_app' + ' --type other' + ' --app-source '+ app_source + ' --environment ' + environment_variable + ' --profile ' + aws_profile_name 
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


######################## CREATING NEW LAYER ############################

cmd = "aws opsworks create-layer --stack-id " + prod_stack_id + ' --name "App Server" --shortname app_server --type custom --profile ' + aws_profile_name
if dry_run
	puts cmd
else
	layer_info = `#{cmd}`
	layer_info = JSON.parse(layer_info)
	layer_id = layer_info['layerId']
	puts layer_id
end

recipe_prefix = root_repo_name + '-dev'

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

ssh_key = get_input("Enter the ssh key to access the git repo for your app: ")
revision = "dev"
# create app
app_source = "Type=git," + git_url + ",SshKey=" + ssh_key + "Revision=" + revision

# there is a chance the database isn't created yet, so keep trying until we get it
endpoint = false

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

cmd = 'aws opsworks create-app --stack-id ' + stack_id + ' --name tesrt_er_app' + ' --type other' + ' --app-source '+ app_source + ' --environment ' + environment_variable + ' --profile ' + aws_profile_name 
if dry_run
	puts cmd
else
	`#{cmd}`
	puts cmd
end