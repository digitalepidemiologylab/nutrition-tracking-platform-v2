# Heroku Hosting

MyFoodRepo V2 is hosted on Heroku, and we utilize the pipeline feature for streamlined deployment. We have two apps set up for this purpose: `myfoodrepo-v2-staging` and `myfoodrepo-v2-production`.

## Staging Deployment

The deployment process begins with the `main` branch, which is automatically deployed to the staging environment when the CI tests pass. We conduct manual quality checks on the staging build to ensure everything works as expected. Once we are satisfied with the testing, we proceed to promote the staging build to the production environment, significantly expediting the deployment process.

## Review Apps

Another valuable feature of Heroku pipelines is the use of review apps. For each open PR, we can create an instance and share its URL for manual testing. For more details on this feature, refer to the [Heroku documentation](https://devcenter.heroku.com/articles/github-integration-review-apps).

## Deployment Procedure

To deploy changes to the production environment, follow this complete deployment procedure:

1. Open a pull request (PR) from your work branch to the `main` branch.
2. In the PR, list all the commands and operations that need to be executed manually before and after the deployment.
3. Wait for the CI tests to pass.
4. Create a review app for the PR and verify that the changes deploy successfully and function as expected.
5. If the CI tests pass, and the review app works as intended, go ahead and `Squash and merge` your PR into the `main` branch.
6. Staging database migration is automatic. However, make sure to run the required rake tasks manually (refer to the PR description).
7. Verify that the staging environment is working correctly.
8. Access the [Heroku interface](https://dashboard.heroku.com/pipelines/94c44bae-7cc8-4d2e-9942-3e13e0759a23) and click "Promote to production" to proceed with deploying to the production environment.
9. Similar to staging, production database migration is automatic, but run any necessary rake tasks manually (as specified in the PR description).
10. Verify that the production environment is working correctly.
11. Announce the successful deployment on Slack with a celebratory emoji 🎉.

Following these steps ensures a smooth and controlled deployment process for MyFoodRepo V2 on Heroku.
