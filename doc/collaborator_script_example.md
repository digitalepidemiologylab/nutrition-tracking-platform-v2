# Collaborator script example

## About the script

As an example on how to use the collaborator API, you'll a [Ruby script](script/export_cohort_annotation_items.rb) is available in the `script` directory of this repo. This script creates a CSV of all annotation items data for a cohort, like it was done in the v1 of MyFoodRepo.

## Requirements

* Ruby >3 installed
* `json-api-vanilla` gem installed (`gem install json-api-vanilla`)

## How to use it

You need to define the following environment variables: Values for these variables ara available once you've created    an API token on your profile page on MyFoodRepo:

```bash
export MFR_UID=your@email.com
export MFR_CLIENT=your-client-id
export MFR_ACCESS_TOKEN=your-access-token
```

After this, you can run the script by replacing {environment} by `local`, `staging` or `production`, replacing the {cohort ID} with the cohort ID you want to export and running it:

```bash
ruby ./script/export_cohort_annotation_items.rb {environment} {cohort ID}
```
