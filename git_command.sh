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
        echo "3) Create Keys"
        echo "4) Make Authentication Key"
        echo "5) Setup Git"
        echo "6) Exit"
        echo
        read -p "Choose an option: " choice
        case $choice in
            1) clone_repositories ;;
            2) mark_repos_safe ;;
            3) create_keys ;;
            4) make_authentication_key ;;
            5) setup_git ;;
            6) echo "Goodbye!"; exit 0 ;;
            *) echo "Invalid option. Please choose 1, 2, 3, 4, 5, or 6." ;;
        esac
    done
}

# Function to clone repositories from repo_list.txt
clone_repositories() {
    echo
    echo "Cloning repositories from repo_list.txt..."
    if [ ! -f repo_list.txt ]; then
        echo "Error: repo_list.txt not found. Please create this file with one repository URL per line."
        return
    fi

    while IFS= read -r repo_url || [ -n "$repo_url" ]; do
        if [[ "$repo_url" =~ ^https?:// || "$repo_url" =~ ^git@ ]]; then
            repo_name=$(basename "$repo_url" .git)
            if [ ! -d "$repo_name" ]; then
                echo "Cloning $repo_url into $repo_name..."
                git clone "$repo_url" "$repo_name"
            else
                echo "Skipping $repo_name: Repository already exists."
            fi
        else
            echo "Skipping $repo_url: Not a valid Git URL."
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

    # Find and add all .git directories as safe
    find "$parent_dir" -name ".git" -type d | while read -r repo; do
        repo_dir=$(dirname "$repo")
        git config --global --add safe.directory "$repo_dir"
        echo "Marked $repo_dir as safe."
    done

    echo "All repositories under $parent_dir have been marked as safe."
}

# Function to create signing keys
create_keys() {
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
