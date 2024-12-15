Here's a **README.md** for your `git_command.sh` script:

---

# Git Command Script

## Overview

This script simplifies common Git-related tasks, providing a streamlined, interactive menu for managing Git repositories, configurations, and SSH keys. It is designed to be cross-platform and supports Linux, macOS, and Windows (using Git Bash).

### Key Features:
- Clone multiple repositories from a list.
- Mark directories as "safe" for Git operations.
- Generate SSH signing keys and configure commit signing.
- Create SSH authentication keys for secure access.
- Easily manage Git configurations (username, email, signing keys).
- Organize and manage allowed signers for SSH-based commit signing.

---

## Prerequisites

To use this script, you need Git installed on your system. Follow the instructions for your platform:

- **Windows**: Download and install [Git for Windows](https://gitforwindows.org/). This includes Git Bash, which is required to run the script.
- **Ubuntu (Linux)**: Install Git using the following command:
  ```bash
  sudo apt update && sudo apt install git -y
  ```
- **macOS**: Install Git using Homebrew:
  ```bash
  brew install git
  ```

---

## How to Use

### 1. Clone or Download the Script
Clone this repository or download the `git_command.sh` script manually.

### 2. Make the Script Executable
Before running the script, ensure it has executable permissions:
```bash
chmod +x git_command.sh
```

### 3. Run the Script
Start the script using the following command:
```bash
./git_command.sh
```

---

## Menu Options

The script provides an interactive menu with the following options:

1. **Clone Repositories**  
   Clone multiple repositories listed in a `repo_list.txt` file. Each line in the file should contain a repository URL.

2. **Mark Repositories Safe**  
   Mark all Git repositories in a specified directory (or the current directory by default) as "safe" for Git operations.

3. **Create Keys**  
   Generate SSH signing keys (e.g., `ed25519` or `ecdsa`) for commit signing. Automatically adds the public key to an `allowed_signers` file.

4. **Make Authentication Key**  
   Generate SSH authentication keys with a unique name (e.g., `id_ed25519_auth`). These keys are not configured automatically, allowing manual setup for authentication purposes.

5. **Setup Git**  
   Configure Git settings, including username, email, and signing keys. Supports both SSH- and GPG-based commit signing.

6. **Exit**  
   Quit the script.

---

## Example `repo_list.txt` File

If you choose the "Clone Repositories" option, the script will look for a file named `repo_list.txt` in the current directory. This file should contain one Git repository URL per line:

```plaintext
https://github.com/your_username/repo1.git
https://github.com/your_username/repo2.git
git@github.com:your_username/repo3.git
```

---

## Licensing

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).  
You are free to use, modify, and distribute this script in accordance with the terms of the license.

---

## Contribution

Contributions are welcome! If you encounter issues or have suggestions for improvements, feel free to open an issue or submit a pull request.

---

## Notes

- For more information about Git, visit the [official Git website](https://git-scm.com/).
- This script is designed for use with Git Bash on Windows and standard Bash shells on Linux and macOS.
- Always ensure your SSH keys and configurations are handled securely.

---
