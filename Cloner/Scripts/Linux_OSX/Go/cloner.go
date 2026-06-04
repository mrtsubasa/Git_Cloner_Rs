package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"os/exec"
)

const maxPerPage = 100
const apiBase = "https://api.github.com"

type Repo struct {
	CloneURL string `json:"clone_url"`
	Name     string `json:"name"`
}

func main() {
	var user string
	fmt.Print("GitHub username / orga name: ")
	fmt.Scan(&user)

	if !userExists(user) {
		fmt.Printf("Error: GitHub user '%s' not found.\n", user)
		os.Exit(1)
	}

	if err := os.MkdirAll(user, 0755); err != nil {
		fmt.Printf("Error creating directory: %v\n", err)
		os.Exit(1)
	}

	if err := os.Chdir(user); err != nil {
		fmt.Printf("Error changing directory: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Fetching repositories for '%s'...\n\n", user)

	total, failed := 0, 0
	page := 1

	for {
		repos, err := fetchRepos(user, page)
		if err != nil || len(repos) == 0 {
			break
		}

		for _, repo := range repos {
			if _, err := os.Stat(repo.Name); !os.IsNotExist(err) {
				fmt.Printf("  [SKIP] %s already exists, pulling latest...\n", repo.Name)
				pull(repo.Name)
			} else {
				fmt.Printf("  [CLONE] %s\n", repo.CloneURL)
				if err := clone(repo.CloneURL); err != nil {
					fmt.Printf("  [ERROR] Failed to clone %s: %v\n", repo.CloneURL, err)
					failed++
				} else {
					total++
				}
			}
		}
		page++
	}

	fmt.Printf("\nDone. %d repositories cloned, %d failed.\n", total, failed)
}

func userExists(user string) bool {
	resp, err := http.Get(fmt.Sprintf("%s/users/%s", apiBase, user))
	if err != nil {
		return false
	}
	defer resp.Body.Close()
	return resp.StatusCode == 200
}

func fetchRepos(user string, page int) ([]Repo, error) {
	url := fmt.Sprintf("%s/users/%s/repos?per_page=%d&page=%d", apiBase, user, maxPerPage, page)
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var repos []Repo
	if err := json.NewDecoder(resp.Body).Decode(&repos); err != nil {
		return nil, err
	}
	return repos, nil
}

func clone(url string) error {
	cmd := exec.Command("git", "clone", "--quiet", url)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func pull(dir string) {
	cmd := exec.Command("git", "-C", dir, "pull", "--quiet")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Run()
}