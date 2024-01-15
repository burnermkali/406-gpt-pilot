#!/bin/bash
# Exit script if any command fails
set -e

# Clone the repository
git clone https://github.com/Pythagora-io/gpt-pilot.git

# Change directory to the cloned repository
cd gpt-pilot

# Create a Python virtual environment
python -m venv pilot-env

# Activate the virtual environment
# Note: This is for Unix-like systems. Windows users should use pilot-env\Scripts\activate
source pilot-env/bin/activate

# Install dependencies
pip install -r requirements.txt

# Move into the pilot directory
cd pilot

# Copy .env.example to .env
# Note: This is for Unix-like systems. Windows users should use 'copy' command
mv .env.example .env

echo "Setup completed successfully."


# Exit if any command fails
set -e

# Function to add or update a variable in .env file
add_or_update_env() {
    local key="$1"
    local value="$2"
    local file=".env"

    # Check if the key exists in the file, if so replace it, if not add it
    if grep -q "^$key=" "$file"; then
        sed -i "s/^$key=.*/$key=$value/" "$file"
    else
        echo "$key=$value" >> "$file"
    fi
}

echo "Configuring .env file for GPT Pilot"

# Prompt for LLM Provider
read -p "Enter your LLM Provider (OpenAI/Azure/Openrouter): " llm_provider
add_or_update_env "LLM_PROVIDER" "$llm_provider"

# Prompt for API Key
read -p "Enter your API key: " api_key
add_or_update_env "API_KEY" "$api_key"

# Prompt for Database Setting
read -p "Enter your database setting (SQLite/PostgreSQL): " db_setting
if [[ $db_setting == "PostgreSQL" ]]; then
    add_or_update_env "DATABASE_TYPE" "postgres"
else
    add_or_update_env "DATABASE_TYPE" "sqlite"
fi

# Prompt for IGNORE_FOLDERS
read -p "Enter folders to ignore (separated by commas, no spaces): " ignore_folders
add_or_update_env "IGNORE_FOLDERS" "$ignore_folders"

# Initialize the database
echo "Initializing the database..."
python db_init.py

# Start GPT Pilot
echo "Starting GPT Pilot..."
python main.py
