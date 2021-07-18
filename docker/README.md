# Docker Offline

## Trusting your Registry

I have yet to see people get lab certificates right; it's just so much easier to
spin up a gitlab with self-signed certs. Here's a quick snippet to trust a local
docker registry:

```bash
sudo mkdir -p /etc/docker/certs.d/gitlab-hostname:5555
sudo su -c "openssl s_client -connect gitlab-hostname:5555 < /dev/null | openssl x509 -outform PEM > /etc/docker/certs.d/gitlab-hostname:5555/ca.crt
```

## Gitlab Kaniko CI

When you want to build a container in CI, you have a couple of options:

- Shell Executor - Could be unsafe, but also super easy
- Docker-in-Docker (DinD) - Uses a docker image on a docker executor. Works, but
  you take a performance hit (and it just feels wrong)
- Kaniko - Uses a docker image on a docker executor that is designed to build
  images. Super easy to use, quick, and my personal favorite

The following snipped was building a python based image, and so you can see the
pip configuration for an offline environment being passed in.

```yaml
pkg-kaniko:
  stage: Package
  image:
    name: ${CI_REGISTRY_HUB}kaniko-executor:debug
    entrypoint: [""]
  script:
    - echo "{\"auths\":{\"$CI_REGISTRY\":{\"username\":\"$CI_REGISTRY_USER\",\"password\":\"$CI_REGISTRY_PASSWORD\"}}}" > /kaniko/.docker/config.json
    # Default to the sha if not a tag event
    - export TAG=${CI_COMMIT_TAG:-$CI_COMMIT_SHA}
    - /kaniko/executor
      --build-arg CI_REGISTRY_HUB="$CI_REGISTRY_HUB"
      --build-arg PIP_INDEX_URL="$PIP_INDEX_URL"
      --build-arg PIP_TRUSTED_HOST="$PIP_TRUSTED_HOST"
      --context $CI_PROJECT_DIR
      --dockerfile $CI_PROJECT_DIR/...
      --destination $CI_REGISTRY_IMAGE:$TAG
      --skip-tls-verify
      --skip-unused-stages
```
