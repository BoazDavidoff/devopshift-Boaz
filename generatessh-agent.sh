#!/bin/bash

# Function to validate repository URL
validate_repo() {
  git ls-remote $1 &> /dev/null
  if [ $? -ne 0 ]; then
    echo "Error: Invalid repository URL or you don't have access."
    exit 1
  fi
}

# Function to generate SSH key
generate_ssh_key() {
  mkdir -p ./keys
  ssh-keygen -t rsa -b 4096 -f ./keys/deploy_key -N ""
  echo "SSH key generated at ./keys/deploy_key"
  echo "Please add the following SSH key to your repository's deploy keys:"
  cat ./keys/deploy_key.pub
  echo
  echo "Go to your repository settings, add a new deploy key, and paste the key above."
  echo "Once done, type 'continue' to proceed."
  read -p "Type 'continue' to proceed: " confirm
  while [ "$confirm" != "continue" ]; then
    read -p "Type 'continue' to proceed: " confirm
  done
}

# Function to add SSH key to ssh-agent
add_ssh_key_to_agent() {
  eval "$(ssh-agent -s)"
  ssh-add ./keys/deploy_key
}

# Function to configure SSH config
configure_ssh_config() {
  ssh_config_path="$HOME/.ssh/config"
  echo -e "Host github.com-repo-0\n\tHostname github.com\n\tIdentityFile=$(pwd)/keys/deploy_key" >> $ssh_config_path
  echo "SSH config updated."
}

# Function to validate SSH connection
validate_ssh_connection() {
  ssh -T git@github.com
  if [ $? -ne 1 ]; then
    echo "Error: SSH connection failed."
    exit 1
  fi
  echo "SSH connection validated."
}

# Function to validate write permission
validate_write_permission() {
  touch test_file
  git add test_file
  git commit -m "Test commit"
  git push origin main
  if [ $? -ne 0 ]; then
    echo "Error: Write permission validation failed."
    exit 1
  fi
  git rm test_file
  git commit -m "Remove test file"
  git push origin main
  echo "Write permission validated."
}

# Main script
read -p "Is this the first run? (yes/no): " first_run
if [ "$first_run" == "yes" ]; then
  read -p "Enter your repository URL: " repo_url
  validate_repo $repo_url
  git clone $repo_url repo
  if [ $? -ne 0 ]; then
    echo "Error: Cloning the repository failed."
    exit 1
  fi
  cd repo
  generate_ssh_key
  add_ssh_key_to_agent
  configure_ssh_config
  validate_ssh_connection
  validate_write_permission
  echo "Setup completed successfully."
else
  echo "Skipping initial setup."
fi