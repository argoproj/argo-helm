import csv
from datetime import datetime


def merge_csv_files(csv_file_1, csv_file_2, output_csv_file):
    # Read the first CSV file into a dictionary
    releases_1 = {}
    with open(csv_file_1, mode="r") as file:
        reader = csv.DictReader(file)
        for row in reader:
            key = (row["Repository"], row["Release Tag"])
            releases_1[key] = row

    # Read the second CSV file and find the oldest release for each appVersion
    oldest_releases = {}
    valid_repos = {"argo-cd", "argo-events", "argo-workflows", "argo-rollouts"}
    with open(csv_file_2, mode="r") as file:
        reader = csv.DictReader(file)
        for row in reader:
            release_name = row["Release Name"]
            repo_name = "-".join(release_name.split("-")[:-1])
            if repo_name in valid_repos:
                app_version = row["App Version"]
                release_datetime = datetime.strptime(
                    f"{row['Release Date']} {row['Release Time']}", "%Y-%m-%d %H:%M:%S"
                )
                if (
                    repo_name,
                    app_version,
                ) not in oldest_releases or release_datetime < oldest_releases[
                    (repo_name, app_version)
                ][
                    "datetime"
                ]:
                    oldest_releases[(repo_name, app_version)] = {
                        "row": row,
                        "datetime": release_datetime,
                    }

    # Merge the oldest releases with the first CSV file
    merged_releases = []
    for (repo_name, app_version), data in oldest_releases.items():
        row = data["row"]
        for key, release in releases_1.items():
            if (
                repo_name == release["Repository"]
                and app_version == release["Release Tag"]
            ):
                time_difference = data["datetime"] - datetime.strptime(
                    f"{release['Release Date']} {release['Release Time']}",
                    "%Y-%m-%d %H:%M:%S",
                )
                time_difference_hours = (
                    time_difference.total_seconds() / 3600
                )  # Convert to hours
                merged_row = {
                    "Repository": release["Repository"],
                    "Release Tag": release["Release Tag"],
                    "Release Date": release["Release Date"],
                    "Release Time": release["Release Time"],
                    "App Version": app_version,
                    "Release Name": row["Release Name"],
                    "Release Date 2": row["Release Date"],
                    "Release Time 2": row["Release Time"],
                    "Time Difference": time_difference_hours,
                }
                merged_releases.append(merged_row)
                break
        else:
            merged_row = {
                "Repository": repo_name,
                "Release Tag": "",
                "Release Date": "",
                "Release Time": "",
                "App Version": app_version,
                "Release Name": row["Release Name"],
                "Release Date 2": row["Release Date"],
                "Release Time 2": row["Release Time"],
                "Time Difference": "",
            }
            merged_releases.append(merged_row)

    # Write the merged data to a new CSV file
    with open(output_csv_file, mode="w", newline="") as file:
        fieldnames = [
            "Repository",
            "Release Tag",
            "Release Date",
            "Release Time",
            "App Version",
            "Release Name",
            "Release Date 2",
            "Release Time 2",
            "Time Difference",
        ]
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        for row in merged_releases:
            writer.writerow(row)

    print(f"Merged data has been written to {output_csv_file}")


# Example usage
if __name__ == "__main__":
    merge_csv_files(
        "argo_releases.csv", "argo_helm_releases.csv", "merged_releases.csv"
    )
