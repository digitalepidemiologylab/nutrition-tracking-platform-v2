# Local Installation

## Base

1. Install Docker on your computer
1. Clone the repository
1. Create a `.env.override` file (`touch .env.override`)
1. Run the following commands:

   ```shell
   docker compose run --rm app rails db:prepare
   docker compose up -d
   ```

1. Go to [http://localhost](http://localhost)

## Use HTTPS locally

Use `mkcert` to install a valid local certificate with the following commands on macOS (if you need another platform, please check the [mkcert documentation](https://github.com/FiloSottile/mkcert))

```bash
brew install mkcert
brew install nss
mkcert -install
```

And from the project directory:

`mkcert -cert-file docker/certs/local-cert.pem -key-file docker/certs/local-key.pem "mfr.localhost"`

The app uses Traefik to redirect mfr.localhost to the right service (`app`). Please add `mfr.localhost 127.0.0.1` in your `/etc/hosts` file to make it working.

After this, go to [https://mfr.localhost](https://mfr.localhost)

You can also find Traefik dashboard at this url: [http://localhost:8080](http://localhost:8080)

## Docker app image management

### Login to the GitHub Container registry

Login to GitHub Container registry with the Docker CLI. You must need to use a GitHub token to authenticate. See [Authenticating to the Container registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry).

`docker login ghcr.io -u YOUR_GITHUB_USERNAME` and enter you GitHub token.

### Info about Mac Silicon (M1)

The `selenium-chrome` service container causes some problems on Mac Silicon (Chrome crashes inside the container). For more info about this problem [see the issue on the Docker Selenium project](https://github.com/SeleniumHQ/docker-selenium/issues/1076)

Currently, there is no "official" way to fix this, but there is a workaround described here: [the ARM fork for Docker Selenium](https://github.com/seleniarm/docker-selenium)

You need to use the `docker-compose.arm64.yml` which overrides the image name of `selenium-chrome`. For that, you can use the environment variable `COMPOSE_FILE` by adding `export COMPOSE_FILE=docker-compose.yml:docker-compose.arm64.yml` in your `bash`/`zsh` profile file. Otherwise, you need to specify the docker compose files for every `docker compose` command. For example:

* to start the services: `docker compose -f docker-compose.yml -f docker-compose.arm64.yml up`
* to run a dev container: `docker compose -f docker-compose.yml -f docker-compose.arm64.yml run --rm dev bash`
