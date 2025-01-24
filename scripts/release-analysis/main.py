import os

from fetch_helmet_releases import fetch_and_write_helmet_releases
from fetch_releases import fetch_and_write_releases
from merge_csvs import merge_csv_files
from plot_graph import plot_time_difference

# Check there is a github token
github_token = os.getenv("GITHUB_TOKEN")
if not github_token:
    raise ValueError("GITHUB_TOKEN environment variable is not set")

# Do the thing
print("Fetching releases...")
fetch_and_write_releases("argo_releases.csv")
print("Done")

print("Fetching Team Helmet releases...")
fetch_and_write_helmet_releases("argo_helm_releases.csv")
print("Done")

print("Merging release info...")
merge_csv_files("argo_releases.csv", "argo_helm_releases.csv", "merged_releases.csv")
print("Done")

print("Plotting time difference graphs...")
plot_time_difference("merged_releases.csv")
print("Done")

# Delete __pycache__ directories
os.system("rm -rf __pycache__")
