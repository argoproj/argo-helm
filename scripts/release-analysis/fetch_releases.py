import csv
import os
from datetime import datetime

import requests

# List of GitHub repository URLs we care about
repos = [
    ("argo-cd", "https://api.github.com/repos/argoproj/argo-cd/releases"),
    ("argo-workflows", "https://api.github.com/repos/argoproj/argo-workflows/releases"),
    ("argo-events", "https://api.github.com/repos/argoproj/argo-events/releases"),
    ("argo-rollouts", "https://api.github.com/repos/argoproj/argo-rollouts/releases"),
]

# Get the GitHub token from environment variables
github_token = os.getenv("GITHUB_TOKEN")
if not github_token:
    raise ValueError("GITHUB_TOKEN environment variable is not set")


# Fetch all releases with pagination
def fetch_all_releases(url):
    releases = []
    headers = {"Authorization": f"token {github_token}"}
    while url:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        releases.extend(response.json())
        url = response.links.get("next", {}).get("url")
    return releases


# Fetch releases and write to a CSV file
def fetch_and_write_releases(csv_file):
    with open(csv_file, mode="w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(["Repository", "Release Tag", "Release Date", "Release Time"])

        for repo_name, repo_url in repos:
            releases = fetch_all_releases(repo_url)
            for release in releases:
                tag_name = release["tag_name"]
                published_at = release["published_at"]
                release_date = datetime.strptime(
                    published_at, "%Y-%m-%dT%H:%M:%SZ"
                ).date()
                release_time = datetime.strptime(
                    published_at, "%Y-%m-%dT%H:%M:%SZ"
                ).time()
                writer.writerow([repo_name, tag_name, release_date, release_time])

    print(f"Release data has been written to {csv_file}")


# Example usage
if __name__ == "__main__":
    fetch_and_write_releases("argo_releases.csv")
