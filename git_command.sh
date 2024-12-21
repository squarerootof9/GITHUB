#!/bin/bash

# Function to display the main menu
main_menu() {
    while true; do
        echo
        echo "======================"
        echo " Git Setup Main Menu"
        echo "======================"
        echo "1) Clone Repositories"
        echo "2) Mark Repositories Safe"
        echo "3) Manage Repositories"
        echo "4) Create New Repository"
        echo "5) Make Signing Key"
        echo "6) Make Authentication Key"
        echo "7) Setup Git"
        echo "8) Exit"
        echo
        read -p "Choose an option: " choice
        case $choice in
            1) clone_repositories ;;
            2) mark_repos_safe ;;
            3) manage_repositories ;;
            4) create_new_repository ;;
            5) make_signing_key ;;
            6) make_authentication_key ;;
            7) setup_git ;;
            8) echo "Goodbye!"; exit 0 ;;
            *) echo "Invalid option. Please choose a valid option." ;;
        esac
    done
}

# Function to manage repositories
manage_repositories() {
    echo
    echo "Searching for cloned repositories in repo_list.txt..."

    if [ ! -f repo_list.txt ]; then
        echo "Error: repo_list.txt not found. Please create this file with one repository URL per line."
        return
    fi

    # Collect list of repositories from repo_list.txt
    local repos=()
    while IFS= read -r repo_url || [ -n "$repo_url" ]; do
        repo_name=$(basename "$repo_url" .git)
        repo_path="$PWD/$repo_name"
        if [ -d "$repo_path/.git" ]; then
            repos+=("$repo_name:$repo_path")
        fi
    done < repo_list.txt

    if [ ${#repos[@]} -eq 0 ]; then
        echo "No cloned repositories found in repo_list.txt."
        return
    fi

    echo "Available Repositories:"
    for i in "${!repos[@]}"; do
        echo "$((i + 1))) ${repos[i]%%:*}"
    done
    echo "$(( ${#repos[@]} + 1 ))) Return to Main Menu"

    read -p "Select a repository: " repo_choice
    if [ "$repo_choice" -gt 0 ] && [ "$repo_choice" -le "${#repos[@]}" ]; then
        selected_repo_name="${repos[$((repo_choice - 1))]%%:*}"
        selected_repo_path="${repos[$((repo_choice - 1))]##*:}"
        echo "Selected Repository: $selected_repo_name at $selected_repo_path"
        repository_menu "$selected_repo_name" "$selected_repo_path"
    else
        echo "Returning to Main Menu."
    fi
}

# Function to create a new repository
create_new_repository() {
    echo
    echo "Create New Repository"
    read -p "Enter the name of the repository directory: " repo_dir
    read -p "Enter the initial commit message: " input_message
    read -p "Enter the path to the remote repository (e.g., git@github.com:username/repo.git): " repo_uri

    if [ ! -d "$repo_dir" ]; then
        echo "Directory does not exist. Creating $repo_dir..."
        mkdir -p "$repo_dir"
    fi

    # Mark the directory as safe for Git operations


    git config --global --add safe.directory "$(cd "$repo_dir" && pwd)"

    echo "Marked $repo_dir as safe."

    # Initialize the repository and push to remote
    pushd "$repo_dir" > /dev/null || { echo "Failed to access directory $repo_dir"; return; }
    echo "# $repo_dir" >> README.md
    git init
    git add README.md
    git add .
    git commit -m "$input_message"
    git branch -M main
    git remote add origin "$repo_uri"
    git push -u origin main
    popd > /dev/null

    # Add the repo URI to repo_list.txt
    echo "$repo_uri" >> repo_list.txt
    echo "Repository created, pushed to remote, and added to repo_list.txt: $repo_uri"
}

# Submenu for repository operations
repository_menu() {
    local repo_name="$1"
    local repo_path="$2"

    while true; do
        echo
        echo "Repository Menu: $repo_name"
        echo "1) Status"
        echo "2) Add All"
        echo "3) Commit"
        echo "4) Push"
        echo "5) Pull"
        echo "6) Fetch"
        echo "7) Other"
        echo "8) Switch Repository"
        echo "9) Main Menu"
        echo
        read -p "Choose an option: " choice
        case $choice in
            1) git -C "$repo_path" status ;;
            2) git -C "$repo_path" add . ;;
            3)
                read -p "Enter commit message: " commit_message
                git -C "$repo_path" commit -m "$commit_message"
                ;;
            4) git -C "$repo_path" push ;;
            5) git -C "$repo_path" pull ;;
            6) git -C "$repo_path" fetch ;;
            7) other_menu "$repo_name" "$repo_path" ;;
            8) manage_repositories; return ;;
            9) return ;;
            *) echo "Invalid option. Please choose a valid option." ;;
        esac
    done
}

# Function for the "Other" menu
other_menu() {
    local repo_name="$1"
    local repo_path="$2"

    while true; do
        echo
        echo "Other Menu: $repo_name"
        echo "1) Resign All and Push"
        echo "2) View Commit History"
        echo "3) New History Starting Point"
        echo "4) Push To New Repository"
        echo "5) Previous Menu"
        echo
        read -p "Choose an option: " choice
        case $choice in
            1)
                git -C "$repo_path" commit --amend --no-edit
                git -C "$repo_path" push --force
                ;;
            2)
                echo "Commit History:"
                git -C "$repo_path" log
                ;;
            3)
                echo "WARNING: This will reset the repository history. This action is NOT reversible."
                read -p "Would you like to continue? (y/N): " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    read -p "Enter the new starting point commit message: " input_message
                    git -C "$repo_path" checkout main
                    git -C "$repo_path" reset --soft "$(git -C "$repo_path" rev-list --max-parents=0 HEAD)"
                    git -C "$repo_path" commit -m "$input_message"
                    git -C "$repo_path" push --force
                    echo "Repository history reset and pushed."
                else
                    echo "Operation canceled."
                fi
                ;;
            4)
                read -p "Enter the path to the remote repository (e.g., git@github.com:username/repo.git): " repo_uri
                git -C "$repo_path" branch -M main
                git -C "$repo_path" remote add origin "$repo_uri"
                git -C "$repo_path" push -u origin main
                echo "Repository pushed to new remote: $repo_uri"
                ;;
            5) return ;;
            *) echo "Invalid option. Please choose a valid option." ;;
        esac
    done
}

# Function to clone repositories
clone_repositories() {
    echo
    echo "Cloning repositories from repo_list.txt..."
    if [ ! -f repo_list.txt ]; then
        echo "Error: repo_list.txt not found. Please create this file with one repository URL per line."
        return
    fi

    while IFS= read -r repo_url || [ -n "$repo_url" ]; do
        repo_name=$(basename "$repo_url" .git)
        if [ ! -d "$repo_name/.git" ]; then
            echo "Cloning $repo_url into $repo_name..."
            git clone "$repo_url" "$repo_name"
        else
            echo "Skipping $repo_name: Repository already exists."
        fi
    done < repo_list.txt
    echo "All repositories processed."
}

# Function to mark repositories as safe
mark_repos_safe() {
    echo
    echo "Marking repositories as safe..."
    read -p "Enter the parent directory containing your repositories (default: current directory): " parent_dir
    parent_dir="${parent_dir:-$(pwd)}"

    find "$parent_dir" -name ".git" -type d | while read -r repo; do
        repo_dir=$(dirname "$repo")
        git config --global --add safe.directory "$repo_dir"
        echo "Marked $repo_dir as safe."
    done

    echo "All repositories under $parent_dir have been marked as safe."
}

# Function to create signing keys
make_signing_key() {
    echo
    echo "Creating SSH keys for signing..."

    # Ask for email
    read -p "Enter your email address to use as the comment: " email

    # Ask for key type
    echo "Select key type:"
    select key_type in "ed25519" "ecdsa"; do
        case $key_type in
            ed25519|ecdsa)
                break
                ;;
            *)
                echo "Invalid option. Please select ed25519 or ecdsa."
                ;;
        esac
    done

    # Ask for normal or passkey
    echo "Do you want to create a normal key or use a hardware-backed passkey?"
    select key_option in "Normal Key" "Passkey"; do
        case $key_option in
            "Normal Key")
                key_suffix=""
                break
                ;;
            "Passkey")
                key_suffix="-sk"
                break
                ;;
            *)
                echo "Invalid option. Please select Normal Key or Passkey."
                ;;
        esac
    done

    # Generate the key
    key_path="$HOME/.ssh/id_${key_type}${key_suffix}"
    ssh-keygen -t "${key_type}${key_suffix}" -f "$key_path" -C "$email"

    # Output signingkey format
    echo "signingkey = $key_path"

    # Configure the allowed signers file
    allowed_signers_file="$HOME/git/allowed_signers"
    mkdir -p "$(dirname "$allowed_signers_file")"
    touch "$allowed_signers_file"

    # Append the public key to the allowed signers file with email prefix
    echo "$email $(cat "${key_path}.pub")" >> "$allowed_signers_file"
    echo "Public key added to allowed signers file: $allowed_signers_file"
}

# Function to create an authentication key
make_authentication_key() {
    echo
    echo "Creating SSH key for authentication..."

    # Ask for email
    read -p "Enter your email address to use as the comment: " email

    # Ask for key type
    echo "Select key type:"
    select key_type in "ed25519" "ecdsa"; do
        case $key_type in
            ed25519|ecdsa)
                break
                ;;
            *)
                echo "Invalid option. Please select ed25519 or ecdsa."
                ;;
        esac
    done

    # Ask for normal or passkey
    echo "Do you want to create a normal key or use a hardware-backed passkey?"
    select key_option in "Normal Key" "Passkey"; do
        case $key_option in
            "Normal Key")
                key_suffix=""
                break
                ;;
            "Passkey")
                key_suffix="-sk"
                break
                ;;
            *)
                echo "Invalid option. Please select Normal Key or Passkey."
                ;;
        esac
    done

    # Generate the key
    auth_key_path="$HOME/.ssh/id_${key_type}${key_suffix}_auth"
    ssh-keygen -t "${key_type}${key_suffix}" -f "$auth_key_path" -C "$email"

    # Output file paths
    echo "Authentication key created at: $auth_key_path"
    echo "Public key:"
    cat "${auth_key_path}.pub"
}

# Function to setup Git
setup_git() {
    echo
    echo "Setting up Git..."

    # Configure user information
    read -p "Enter your Git username: " git_username
    git config --global user.name "$git_username"
    read -p "Enter your Git email address: " git_email
    git config --global user.email "$git_email"

    # Configure signing keys
    read -p "Enter the path to your signing key (or leave blank to skip): " key_path
    if [ -n "$key_path" ]; then
        git config --global user.signingkey "$key_path"

        echo "Is this key for SSH or GPG?"
        select format in "SSH" "GPG"; do
            case $format in
                SSH)
                    git config --global gpg.format ssh
                    allowed_signers_file="$HOME/git/allowed_signers"
                    mkdir -p "$(dirname "$allowed_signers_file")"
                    touch "$allowed_signers_file"
                    git config --global gpg.ssh.allowedSignersFile "$allowed_signers_file"
                    git config --global commit.gpgsign true
                    git config --global tag.gpgsign true
                    echo "SSH signing configured. Allowed signers file created at $allowed_signers_file."
                    break
                    ;;
                GPG)
                    git config --global gpg.format gpg
                    git config --global commit.gpgsign true
                    git config --global tag.gpgsign true
                    echo "GPG signing configured."
                    break
                    ;;
                *)
                    echo "Invalid option. Please select SSH or GPG."
                    ;;
            esac
        done
    else
        echo "Signing key setup skipped."
    fi

    # Display configuration summary
    echo
    echo "Final Git Configuration:"
    echo "-------------------------"
    git config --list | grep -E "user\.name|user\.email|signingkey|gpg\.format|commit\.gpgsign|tag\.gpgsign|gpg\.ssh\.allowedSignersFile"
    echo "Git setup complete!"
}

# Run the main menu
main_menu
