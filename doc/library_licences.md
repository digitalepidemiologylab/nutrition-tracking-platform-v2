# Library Licences

## Ruby

To get the list of all gem licences, run the following code in a Rails console:

```ruby
Gem.loaded_specs.each do |name, spec|
  puts "\"#{name}\",\"#{spec.version}\",\"#{spec.license}\",\"#{spec.homepage}\",\"#{spec.summary}\""
end; nil
```

and copy/past the result in a CSV file.

## Javascript

To get the list of all Javascript library license, run the following command:

```bash
yarn licenses list --json  | tail -n 1 | jq -r '.data.body[] | .[0] + "," + .[1] + "," + .[2] + "," + .[3]' > output_js.csv
```

and the result can be found in the `output_js.csv` file.
