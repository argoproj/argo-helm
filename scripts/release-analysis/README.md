# argo-helm release analysis

Compare the time of the upstream release to the time of the equivalent Helm Chart release to determine the time it takes for a new release to be available in argo-helm.


## How to run
This is quite github-api-intensive, so you'll need a github PAT. The PAT only requires public read (to fetch the data from the public repos without being too rate limited).

```bash
# Build the container
docker build . -t team-helm-analysis

# Delete any existing data
rm -f argo_helm_releases.csv argo_releases.csv merged_releases.csv time_difference_plot_argo*.png

# Run the container
GITHUB_TOKEN=your_token_here
docker run --rm -e GITHUB_TOKEN=$GITHUB_TOKEN -v ${PWD}:/app team-helm-analysis
```

You should get 3 csvs and 4 graphs once this completes. It takes around 5 mins to run.


## Linting
I ran megalinter against this just to give some confidence that it's not completely broken. It's not perfect, but it's something.

Run megalinter locally against this directory with: `docker run --rm -v /var/run/docker.sock:/var/run/docker.sock:rw -v $(pwd):/tmp/lint:rw oxsecurity/megalinter:v8`
