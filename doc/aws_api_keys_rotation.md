# AWS API keys rotation

To automatically rotate AWS API keys, simply run the following command from the root of the project:

```bash
./script/rotate_aws_keys.sh
```

## Dependencies

* `aws` CLI (Amazon Web Services) + authenticated with a user who has the right to manage user keys
* `jq` tool
* `op` CLI (1Passowrd) + authenticated with a user who has the right to access to the vault where is the AWS API keys
