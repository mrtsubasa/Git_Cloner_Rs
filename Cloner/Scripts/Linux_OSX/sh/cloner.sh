#!/bin/bash
MAX_PER_PAGE=100
read -p "GitHub username / orga name: " USER

if ! curl -sf "https://api.github.com/users/$USER" > /dev/null; then
    echo "Error: GitHub user '$USER' not found."
    exit 1
fi

mkdir -p "$USER"
cd "$USER" || exit 1

echo "Fetching repositories for '$USER'..."

page=1
total=0
failed=0

while true; do
    repos=$(curl -s "https://api.github.com/users/$USER/repos?per_page=$MAX_PER_PAGE&page=$page" | jq -r '.[].clone_url')

    [ -z "$repos" ] && break

    while IFS= read -r repo; do
        repo_name=$(basename "$repo" .git)

        if [ -d "$repo_name" ]; then
            echo "  [SKIP] $repo_name already exists, pulling latest..."
            git -C "$repo_name" pull --quiet
        else
            echo "  [CLONE] $repo"
            if git clone --quiet "$repo"; then
                ((total++))
            else
                echo "  [ERROR] Failed to clone $repo"
                ((failed++))
            fi
        fi
    done <<< "$repos"

    ((page++))
done

echo ""
echo "Done. $total repositories cloned, $failed failed."