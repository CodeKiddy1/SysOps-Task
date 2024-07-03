#!/bin/bash

# Script to create users and groups, set up home directories, generate random passwords,
# and log all actions to /var/log/user_management.log. Passwords are stored securely in /var/secure/user_passwords.txt.

# Define file paths
FILE="user_groups.txt"
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Ensure the log file and password file exist and are writable
sudo touch "$LOG_FILE"
sudo chmod 600 "$LOG_FILE"

sudo mkdir -p /var/secure
sudo touch "$PASSWORD_FILE"
sudo chmod 600 "$PASSWORD_FILE"

# Function to generate a random password
generate_password() {
  local password_length=12
  # Using openssl to generate a random password
  openssl rand -base64 $((password_length * 3 / 4))
}

# Check if the user_groups.txt file exists
if [ ! -f "$FILE" ]; then
  echo "Error: $FILE not found!" | sudo tee -a "$LOG_FILE"
  exit 1
fi

# Process each line of the file
while IFS=';' read -r user groups; do
  # Trim whitespace from user and groups
  user=$(echo "$user" | xargs)
  groups=$(echo "$groups" | xargs)

  # Create a personal group with the same name as the user if it doesn't exist
  if getent group "$user" &>/dev/null; then
    echo "Personal group $user already exists." | sudo tee -a "$LOG_FILE"
  else
    if sudo groupadd "$user"; then
      echo "Personal group $user created." | sudo tee -a "$LOG_FILE"
    else
      echo "Error: Failed to create personal group $user." | sudo tee -a "$LOG_FILE"
      continue
    fi
  fi

  # Check if user already exists
  if id "$user" &>/dev/null; then
    echo "User $user already exists. Skipping user creation." | sudo tee -a "$LOG_FILE"
  else
    # Generate a random password for the new user
    password=$(generate_password)

    # Create the user with the personal group as the primary group
    if sudo useradd -m -s /bin/bash -g "$user" "$user"; then
      echo "$user:$password" | sudo chpasswd
      echo "User $user created with home directory and personal group." | sudo tee -a "$LOG_FILE"

      # Set ownership and permissions for the user's home directory
      sudo chown "$user:$user" "/home/$user"
      sudo chmod 700 "/home/$user"
      echo "Home directory for $user set with proper permissions." | sudo tee -a "$LOG_FILE"

      # Log the password in the secure password file
      echo "$user:$password" | sudo tee -a "$PASSWORD_FILE"
    else
      echo "Error: Failed to create user $user." | sudo tee -a "$LOG_FILE"
      continue
    fi
  fi

  # Process each additional group the user should belong to
  IFS=',' read -ra groupArray <<< "$groups"
  for group in "${groupArray[@]}"; do
    # Trim whitespace from each group name
    group=$(echo "$group" | xargs)

    # Check if the group already exists
    if getent group "$group" &>/dev/null; then
      echo "Group $group already exists." | sudo tee -a "$LOG_FILE"
    else
      # Create the group if it doesn't exist
      if sudo groupadd "$group"; then
        echo "Group $group created." | sudo tee -a "$LOG_FILE"
      else
        echo "Error: Failed to create group $group." | sudo tee -a "$LOG_FILE"
        continue
      fi
    fi

    # Add the user to the additional group
    if sudo usermod -aG "$group" "$user"; then
      echo "User $user added to group $group." | sudo tee -a "$LOG_FILE"
    else
      echo "Error: Failed to add user $user to group $group." | sudo tee -a "$LOG_FILE"
    fi
  done
done < "$FILE"

echo "All users and groups have been processed." | sudo tee -a "$LOG_FILE"

