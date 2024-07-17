#!/bin/bash

# Ensure jq and fzf are installed
if ! command -v jq &> /dev/null; then
    echo "jq could not be found. Please install jq to use this script."
    exit 1
fi

if ! command -v fzf &> /dev/null; then
    echo "fzf could not be found. Please install fzf to use this script."
    exit 1
fi

# Define the JSON file
JSON_FILE="projects.json"

# Function to handle the login command
function handle_login {
    echo "Executing login command..."
    gcloud auth login
    echo "Logged in!"
}

while true; do
    # Present the main menu including "login"
    MAIN_MENU=("login" $(jq -r 'keys[]' "$JSON_FILE"))

    # Present a menu with all options using fzf
    OPTION=$(printf "%s\n" "${MAIN_MENU[@]}" | fzf --prompt "Select an project: ")

    if [[ -z "$OPTION" ]]; then
        echo "No project selected. Exiting."
        exit 1
    elif [[ "$OPTION" == "Login" ]]; then
        handle_login
    else
        # Check if the selected option is a project
        PROJECT_NAME="$OPTION"

        while true; do
            # Read the regions related to the selected project into an array and add a "Go back" option
            mapfile -t REGIONS < <(jq -r --arg PROJECT_NAME "$PROJECT_NAME" '.[$PROJECT_NAME].regions | keys[]' "$JSON_FILE")

            # Check if there are regions to display
            if [[ ${#REGIONS[@]} -eq 0 ]]; then
                echo "No regions found for project '$PROJECT_NAME'. Going back to main menu."
                break
            fi

            REGIONS=("Go back" "${REGIONS[@]}")

            # Present a menu with all regions for the selected project using fzf
            REGION=$(printf "%s\n" "${REGIONS[@]}" | fzf --prompt "Select a region '$PROJECT_NAME': ")

            if [[ -z "$REGION" ]]; then
                echo "No region selected. Going back to main menu."
                break
            elif [[ "$REGION" == "Go back" ]]; then
                break
            else
                while true; do
                    # Read the hosts related to the selected project and region into an array and add a "Go back" option
                    mapfile -t HOSTS < <(jq -r --arg PROJECT_NAME "$PROJECT_NAME" --arg REGION "$REGION" '.[$PROJECT_NAME].regions[$REGION][]' "$JSON_FILE")

                    # Check if there are hosts to display
                    if [[ ${#HOSTS[@]} -eq 0 ]]; then
                        echo "No hosts found for project '$PROJECT_NAME' and region '$REGION'. Going back to region selection."
                        break
                    fi

                    HOSTS=("Go back" "${HOSTS[@]}")

                    # Present a menu with all hosts for the selected project and region using fzf
                    HOST=$(printf "%s\n" "${HOSTS[@]}" | fzf --prompt "Select a host to connect to '$PROJECT_NAME' and region '$REGION': ")

                    if [[ -z "$HOST" ]]; then
                        echo "No host selected. Going back to region selection."
                        break
                    elif [[ "$HOST" == "Go back" ]]; then
                        break
                    else
                        # Display the selected host and its region
                        echo "Selected host: $HOST"
                        echo "Region: $REGION"
                        gcloud compute ssh  --zone "$REGION" "$HOST" --tunnel-through-iap --project "$PROJECT_NAME"
                        exit 0
                    fi
                done
            fi
        done
    fi
done