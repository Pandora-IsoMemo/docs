# Pandora-Isomemo Documentation Hub

This repository contains the documentation for all our Shiny Apps & R Packages.
It provides detailed information about each project, including setup 
instructions, links to live versions, and other relevant details.

The documentation for each R package is built using `pkgdown` in each
respective repository.

This overview is generated with `Quarto` and is built automatically via GitHub
Actions.

## Adding new Apps to the Documentation

To add a new app or package to this documentation, you need to add an image
to the `img` directory and define the app in the `packages.yaml` file as
follows:

```yaml
categories:
  apps:
    - name: "<name of the app / package>"
      full_name: "< Full name of the App>"
      info_text: |
        <A longer description of the app>
      repo_url: "https://github.com/Pandora-IsoMemo/<appname>"
      doc_url: "https://pandora-isomemo.github.io/<appname>/"
      app_url: "https://pandoraapp.earth/app/<appname>"
      app_beta_url: "https://pandoraapp.earth/app/<appname>-beta"
      docker_image: "<docker-image-name>"
      img: "img/<app-image-file>"
```

## Testing Changes locally

To test changes locally, use the following commands:

```bash
quarto preview
# or
# quarto render
```
