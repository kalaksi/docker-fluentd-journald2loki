
## Repositories
- [Docker Hub repository](https://hub.docker.com/r/kalaksi/fluentd-journald2loki/)
- [GitHub repository](https://github.com/kalaksi/docker-fluentd-journald2loki)

## What is this container for?
This container runs Fluentd which ingests journald/systemd logs (including container logs) and sends them to Grafana Loki.
Configuration is simple and it's possible to get things going with only a few variables.  
  
The FluentD installation includes these additional plugins: `fluent-plugin-systemd`, `fluent-plugin-grafana-loki` and `fluent-plugin-rewrite-tag-filter`.

## Why use this container?
**Simply put, this container has been written with simplicity and security in mind.**

Many community containers run unnecessarily with root privileges by default and don't provide help for dropping unneeded CAPabilities either.
On top of that, overly complex shell scripts, monolithic designs and unofficial base images make it harder to verify the source among other issues.  

To remedy the situation, these images have been written with security, simplicity and overall quality in mind.

|Requirement              |Status|Details|
|-------------------------|:----:|-------|
|Don't run as root        |❌    | Can be run without root, but root is required if you want to use systemd/journald.|
|Official base image      |✅    | |
|Drop extra CAPabilities  |✅    | See ```docker-compose.yml``` |
|No default passwords     |✅    | No static default passwords. That would make the container insecure by default. |
|Support secrets-files    |⚠     | Not at the moment, but you can still keep secrets directly in the configuration files instead of variables.|
|Handle signals properly  |✅    | |
|Simple Dockerfile        |✅    | No overextending the container's responsibilities. And keep everything in the Dockerfile if reasonable. |
|Versioned tags           |✅    | Offer versioned tags for stability.|

## Supported tags
See the ```Tags``` tab on Docker Hub for specifics. Basically you have:
- The default ```latest``` tag that always has the latest changes.
- Minor versioned tags (follow Semantic Versioning), e.g. ```1.1``` which would follow branch ```1.1.x``` on GitHub.

## Configuration
### General
See ```Dockerfile``` and ```docker-compose.yml``` (<https://github.com/kalaksi/docker-fluentd-journald2loki>) for usable environment variables.

### Logs from Docker
You should change Docker's log backend from JSON-file based to journald.
This can be achieved by defining the log-driver in `/etc/docker/daemon.json`. For example:
```
{ "log-driver": "journald", "log-opts": { "tag": "container/{{.Name}}/{{.ID}}" } }
```

(One could also probably utilise FluentD's Docker input plugin but this isn't currently supported with this container.)

### FluentD
For custom Fluentd configuration, you can either mount a directory on `/fluentd/etc/conf.d` or individual files under it, e.g. to `/fluentd/etc/conf.d/50-mysettings.conf`.  
  
A simple setup should need no user-defined configuration files.  
If you have a small number of configuration files that you want to use, it can be more straightforward to mount individual file(s) under `conf.d`.  
If you mount a directory on `conf.d`, it will be populated with the default configuration. Existing files won't be overwritten. If you want to disable individual configuration files
, you need to add suffix `.disabled` in their name.

## Development

### Contributing
See the repository on <https://github.com/kalaksi/docker-fluentd-journald2loki>.
All kinds of contributions are welcome!

## License
Copyright (c) 2020 kalaksi@users.noreply.github.com. See [LICENSE](https://github.com/kalaksi/docker-fluentd-journald2loki/blob/master/LICENSE) for license information.  

As with all Docker images, the built image likely also contains other software which may be under other licenses (such as software from the base distribution, along with any direct or indirect dependencies of the primary software being contained).  
  
As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
