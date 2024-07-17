# Bash utility for GCP

This utility facilitates connecting to your GCP compute engine vms using gcloud and ssh tunnel

Just add your projects, regions and hosts to the projects.json file

```
{
  "Project1": {
    "regions": {
      "us-east4-a": [
        "host1.example.com",
        "host2.example.com"
      ],
      "us-west4-a": [
        "host1.example.com",
        "host2.example.com"
      ]
    }
  },
  "Project2": {
    "regions": {
      "us-east4-a": [
        "host1.example.com",
        "host2.example.com"
      ],
      "us-west4-a": [
        "host1.example.com",
        "host2.example.com"
      ]
    }
  }
}
```
