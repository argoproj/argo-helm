helm_artifact(
  name="redis-ha",
  artifact="redis-ha",
  version="4.29.4",
  repository="https://dandydeveloper.github.io/charts/"
)

helm_chart(
    name="k-argo",
    registries=["@klaviyo-dev", "@klaviyo-eng", "@klaviyo-prod"],
    repository="k-argo",
    dependencies=[":redis-ha"],
)
