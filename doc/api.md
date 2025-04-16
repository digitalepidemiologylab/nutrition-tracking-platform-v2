# API

MyFoodRepo API V2 follows [JSON:API](https://jsonapi.org/) specifications.

Two different API are availables:

- User API V2: API mainly used by the mobile apps ([documentation](/en/collab/api_documentation/api_v2))
- Collab API V1: API available to collaborators to create participations and download data  ([documentation](/en/collab/api_documentation/collab_api_v1))

The API documentations are generated automatically when running the [rswag](https://github.com/rswag/rswag) specs located in `/spec/requests/api/v2/rswag/` with the `rails rswag` command.

Warning: if you don't use the `.env` file, please make sure to run the `rails rswag` command with `SWAGGER_DRY_RUN=0`. See [this issue](https://github.com/rswag/rswag/issues/511) in the rswag repo.

We use [devise_token_auth](https://github.com/lynndylanhurley/devise_token_auth) as a library to authentify users in the API.

You'll also find a `REST-client` testable file here: [API Endpoints](doc/api_endpoints.http).

A user needs first to sign in with email and password to get back in the response a series of authentication params be sent as headers during further requests (`access-token`, `client` and `uid`).

Requests made to `/api/v2` with the MyFoodRepo mobile apps check for the version number of the app in the `user-agent` header. Currently both iOS and Android versions >= 3.0.0 are supported.
The be successfully checked, the user-agent header should be formatted as follow:

- `user-agent: MyFoodRepo/3.0.0 (iOS 16.1; build:131)` (supported version number)
- `user-agent: MyFoodRepo/2.0.0 (iOS 16.1; build:131)` (unsupported version number)
