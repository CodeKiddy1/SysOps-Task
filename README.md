# User and Group Management Bash Script

This bash script automates the creation of user accounts and management of groups on a Linux system. It sets up home directories, generates random passwords securely, and logs actions for accountability.

## Features

- **User Creation**: Creates new user accounts with specified groups.
- **Group Management**: Ensures user membership in both personal and additional groups.
- **Password Security**: Generates and logs secure passwords for each user.
- **Logging**: Records all activities in `/var/log/user_management.log`.
- **Usage of Script**: Ensure `user_groups.txt` is correctly formatted with usernames and groups separated by `;`.

## Requirements

- Linux environment with `bash` shell.
- Administrative privileges (`sudo`) to execute user and group management commands.

## Usage

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/CodeKiddy1/SysOps-Task.git
   cd SysOps-Task
## Prepare user_groups.txt
Create a file named user_groups.txt in the repository root.
Format each line as username;group1,group2,....

## Run the Script

sudo ./create_users.sh

## Verify Log Files

Check /var/log/user_management.log for detailed script activities and Securely store user passwords logged in /var/secure/user_passwords.txt.


