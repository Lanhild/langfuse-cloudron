# Starter Cloudron App

<!-- This is the place for the description of your application. It's usage, description, and potential dependencies. -->

This repository contains the Cloudron app package source for Starter, a template Cloudron application.

The package aims to set global development standards for Cloudron packages to ensure uniformity and ease of sharing.

## Configuration

1. Run `npm run prepare:init`
1. Copy `.env.development.local` to `.env`, and fill-in the appropriate values.

> Make sure that `id` and `version` are defined in `CloudronManifest.json` before building to prevent errors.

## Installation

The scripts assume you already have the application installed on your server.

Run the appropriate `npm` script based on your needs:

```bash
# Update the application specified in PROD_APP_ENDPOINT
npm run update:prod

# OR
# Update the application specified in TEST_APP_ENDPOINT
npm run update:test
```

## Building

Building can be done using `npm run build`.
This script automatically builds and pushes a Docker image tagged with the `id` and `version` defined in `CloudronManifest.json`

## Update checklist

<!-- You can add various tasks that need to be done before updating an application. -->

- [ ]
