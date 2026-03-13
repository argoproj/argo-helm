import csv

import matplotlib.pyplot as plt
from packaging import version


def plot_time_difference(csv_file):
    # Read the CSV file and process the data
    data = {"argo-cd": [], "argo-events": [], "argo-workflows": [], "argo-rollouts": []}
    release_tags = {
        "argo-cd": [],
        "argo-events": [],
        "argo-workflows": [],
        "argo-rollouts": [],
    }
    with open(csv_file, mode="r") as file:
        reader = csv.DictReader(file)
        for row in reader:
            repo = row["Repository"]
            time_diff_str = row["Time Difference"]
            release_tag = row["Release Tag"]
            if repo in data and time_diff_str:
                time_diff = float(time_diff_str)
                data[repo].append(time_diff)
                release_tags[repo].append(release_tag)

    # Sort the release tags based on semantic versioning
    for repo in release_tags:
        sorted_indices = sorted(
            range(len(release_tags[repo])),
            key=lambda i: version.parse(release_tags[repo][i]),
        )
        release_tags[repo] = [release_tags[repo][i] for i in sorted_indices]
        data[repo] = [data[repo][i] for i in sorted_indices]

    # Plot the data
    for repo, time_diffs in data.items():
        plt.figure(figsize=(10, 6))
        plt.plot(release_tags[repo], time_diffs, marker="o", label=repo)
        plt.axhline(y=72, color="r", linestyle="--", label="SLA (72 hours)")
        plt.xlabel("Upstream Release Tag")
        plt.ylabel(
            "Time difference between upstream release and Helm Chart release (hours)"
        )
        plt.title(f"Time to Release Helm Chart for {repo}")
        plt.legend()
        plt.grid(True)
        plt.xticks(rotation=45)
        plt.tight_layout()
        plt.savefig(f"time_difference_plot_{repo}.png")
        plt.close()

    print("The plots have been saved as 'time_difference_plot_<repo>.png'")


# Example usage
if __name__ == "__main__":
    plot_time_difference("merged_releases.csv")
