import csv
import os
from datetime import datetime

import requests

# GitHub repository URL
repo_url = "https://api.github.com/repos/argoproj/argo-helm/releases"

# Get the GitHub token from environment variables
github_token = os.getenv("GITHUB_TOKEN")
if not github_token:
    raise ValueError("GITHUB_TOKEN environment variable is not set")


# Function to fetch all releases with pagination
def fetch_all_releases(url):
    releases = []
    headers = {"Authorization": f"token {github_token}"}
    while url:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        releases.extend(response.json())
        url = response.links.get("next", {}).get("url")
    return releases


# Function to get the content of Chart.yaml in a release
def get_chart_yaml(repo, tag, chart_path):
    url = f"https://raw.githubusercontent.com/{repo}/refs/tags/{tag}/charts/{chart_path}/Chart.yaml"
    headers = {"Authorization": f"token {github_token}"}
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.text
    return None


# Function to extract appVersion from Chart.yaml content
def extract_app_version(chart_yaml):
    for line in chart_yaml.splitlines():
        if line.startswith("appVersion:"):
            return line.split(":")[1].strip()
    return None


# Function to fetch releases and write to a CSV file
def fetch_and_write_helmet_releases(csv_file):
    # Fetch all releases
    releases = fetch_all_releases(repo_url)

    # Write the release data to the CSV file
    with open(csv_file, mode="w", newline="") as file:
        writer = csv.writer(file, quoting=csv.QUOTE_NONE, escapechar="\\")
        writer.writerow(["Release Name", "Release Date", "Release Time", "App Version"])

        for release in releases:
            tag_name = release["tag_name"]
            published_at = release["published_at"]
            release_date = datetime.strptime(published_at, "%Y-%m-%dT%H:%M:%SZ").date()
            release_time = datetime.strptime(published_at, "%Y-%m-%dT%H:%M:%SZ").time()

            # Extract chart path from the release name
            chart_path = "-".join(tag_name.split("-")[:-1])
            current_chart_yaml = get_chart_yaml(
                "argoproj/argo-helm", tag_name, chart_path
            )

            if current_chart_yaml:
                current_app_version = extract_app_version(current_chart_yaml)
                writer.writerow(
                    [tag_name, release_date, release_time, current_app_version]
                )

    # Read the CSV file, remove any instances of `\"`, and write back the cleaned content
    with open(csv_file, mode="r") as file:
        content = file.read()

    cleaned_content = content.replace('\\"', "")

    with open(csv_file, mode="w", newline="") as file:
        file.write(cleaned_content)

    print(
        f'Release data has been written to {csv_file} and cleaned of any instances of \\"'
    )


# Example usage
if __name__ == "__main__":
    fetch_and_write_helmet_releases("argo_helm_releases.csv")
