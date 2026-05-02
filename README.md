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
./scripts/build-site.sh
```

Why this wrapper exists:

- Zola renders pages with `path = "...html"` as directories containing `index.html`.
- The live site at `https://felx.me` serves post URLs as exact file-like paths such as `/2021/08/29/improving-the-hacker-news-ranking-algorithm.html`.
- The trailing-slash variants like `/2021/08/29/improving-the-hacker-news-ranking-algorithm.html/` do not match the live site behavior.
- `scripts/build-site.sh` therefore runs Zola and then normalizes the output so GitHub Pages publishes literal `.html` files at the existing post URLs.

Build the reproducible Nix package:

```sh
nix build
```

## GitHub Pages

The repository is prepared for deployment with GitHub Pages through GitHub Actions.

- The workflow builds the site in CI and uploads the generated `public/` directory.
- Legacy blog post URLs such as `/2021/08/29/improving-the-hacker-news-ranking-algorithm.html` are preserved by a required post-build normalization step.
- The custom domain should remain configured in the repository's GitHub Pages settings as `felx.me`.

## Licensing

The website content is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
