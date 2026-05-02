# felx.me

This repository now builds the site with [Zola](https://www.getzola.org/) and Nix.

## Development

Enter the development shell:

```sh
nix develop
```

Serve the site locally with live reload:

```sh
zola serve
```

## Build

Build the static site locally:

```sh
zola build
```

Build the reproducible Nix package:

```sh
nix build
```

## GitHub Pages

The repository is prepared for deployment with GitHub Pages through GitHub Actions.

- The workflow builds the site in CI and uploads the generated `public/` directory.
- Posts are organized as Zola page bundles, with article assets colocated next to each `index.md`.
- Legacy blog post URLs such as `/2021/08/29/improving-the-hacker-news-ranking-algorithm.html` are preserved through Zola aliases that redirect to the canonical bundle URLs.
- The custom domain should remain configured in the repository's GitHub Pages settings as `felx.me`.

## Licensing

The website content is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
