# jq

## `[]`

`.foo[]` means "every child value under foo". Use it to get all child objects or elements of an array.

## `to_entries`
Converts keys and their objects of JSON object to named `{"key": , "value": }` for further accessing them by `.key` and `.value`.
```shell
# from
	{"a": 1, "b": 2}
# to
	[{"key":"a", "value":1}, {"key":"b", "value":2}]
```

`jq '[.content | to_entries | {(.key): .value.text}]' content.json`

## `from_entries`
Converts an array of objects to a single object.

```shell
# from
    [{"key":"a", "value":1}, {"key":"b", "value":2}]
# to
	{"a": 1, "b": 2}
```

## Extract content from nested arrays
Example input, for example from a HTTP response:
```json
{
    "responseCode": 200,
    "message": "success",
    "content": {
        "teamCount": 1,
        "teams": [
            {
                "id": "243090469994066",
                "name": "Team Name",
                "teamspace_id": "243090513498055",
                "creator": "ogra0034",
                "owner": "ogra0034",
                "memberCount": "2",
                "members": [
                    {
                        "username": "user1",
                        "name": "First Last",
                        "email": "first.last@mail.com",
                        "jobTitle": "Disability Advisor",
                        "accountLockout": "0"
                    }
                ],
                "other": "Other content"
            }
        ]
    }
}
```

jq expression:
```shell
jq '[.content.teams.[] | {"name": .name, "members": [.members.[] | {"name": .name, "email": .email, "title": .jobTitle}]}]' response.json
```

Result:
```json
[
    {
        "name": "Team Name",
        "members": [
            {
            "name": "Carolyn Lake",
            "email": "carolyn.lake@flinders.edu.au",
            "title": "Coordinator, City Campus Services"
            }
        ]
    }
]
```

## Extract from an array
Example:
```json
[
    {
        "LogicalName": "AttributePicklistValue",
        "Id": "5968b273-e605-4ff7-8765-3f7ba1bcaf5a",
        "Attributes": [
            {
                "Key": "value",
                "Value": "11111"
            },
            {
                "Key": "attributepicklistvaluerowid",
                "Value": "8f631a00-23fc-4e8f-a998-994d7b19e8fe"
            },
            {
                "Key": "DisplayName - LocalizedLabel",
                "Value": "{\"LabelTypeCode\":2,\"LocalizedLabels\":{\"1033\":{\"LocalizedLabelId\":\"faed30b7-64e8-4999-bc17-a878a2f3f3b9\",\"LocalizedLabel\":\"Awaiting OGR assessment\",\"ComponentState\":\"Publish\"}}}"
            }
        ]
    },
    {
        "LogicalName": "AttributePicklistValue",
        "Id": "5968b273-e605-4ff7-8765-3f7ba1bcaf5a",
        "Attributes": [
            {
                "Key": "value",
                "Value": "2222"
            },
            {
                "Key": "attributepicklistvaluerowid",
                "Value": "8f631a00-23fc-4e8f-a998-994d7b19e8fe"
            },
            {
                "Key": "DisplayName - LocalizedLabel",
                "Value": "{\"LabelTypeCode\":2,\"LocalizedLabels\":{\"1033\":{\"LocalizedLabelId\":\"faed30b7-64e8-4999-bc17-a878a2f3f3b9\",\"LocalizedLabel\":\"Awaiting OGR assessment\",\"ComponentState\":\"Publish\"}}}"
            }
        ]
    }
]
```

### JSON array of objects { value, display }
```shell
jq '
  map(
    # Turn the Attributes [{Key,Value}...] into a normal object
    (.Attributes | map({key: .Key, value: .Value}) | from_entries) as $a
    | {
        value: $a.value,
        display: (
          try (
            $a["DisplayName - LocalizedLabel"]
            | fromjson                          # parse the embedded JSON string
            | .LocalizedLabels["1033"].LocalizedLabel
          ) catch null
        )
      }
  )
' example.json
```

Result
```json
[
  {
    "value": 1111,
    "display": "Incomplete application"
  },
  {
    "value": 2222,
    "display": "Submitted"
  }
]
```

### From two-column csv to JSON object of key-value pairs
Example CSV data (countries.csv)
```csv
name,code
Australia,882070000
Adelie Land (France),882070001
Afghanistan,882070002
Aland Islands,882070003
Albania,882070004
```

```shell
jq -R -s 'split("\n")  | .[1:] | map(split(",")) | map({key: .[0], value: .[1]}) | from_entries' countries.csv
```

Result
```json
{
  "Australia": "882070000",
  "Adelie Land (France)": "882070001",
  "Afghanistan": "882070002",
  "Aland Islands": "882070003",
  "Albania": "882070004"
}
```

Note:
1. `-R` (Raw input): treats the incoming file as a plain text string.
1. `-s` (Slurp): Reads the entire file into memory as one single string, allowing you to split it by newlines (\n).
1. `.[1:]`: if there is a head line, use this to read from line 1.
1. `map(split(","))`: splits line by delimiter to create:
    ```json
    [
        [
            "Australia",
            "882070000"
        ],
        [
            "Adelie Land (France)",
            "882070001"
        ],
        [
            "Afghanistan",
            "882070002"
        ],
        [
            "Aland Islands",
            "882070003"
        ],
        [
            "Albania",
            "882070004"
        ]
    ]
    ```
1. `map({key: .[0], value: .[1]})`: converts array elements to JSON object.

### CSV with headers value,display
```shell
jq -r '
  ["value","display"],
  (
    .[]
    | (.Attributes | map({key: .Key, value: .Value}) | from_entries) as $a
    | [
        $a.value,
        (try ($a["DisplayName - LocalizedLabel"] | fromjson | .LocalizedLabels["1033"].LocalizedLabel) catch "")
      ]
  )
  | @csv
' example.json
```

Result
```csv
"value","display"
1111,"Incomplete application"
2222,"Submitted"
```

Another example of ignoring keys and extract two fields `name` and `text` as two cells:
`jq -r '.content[] | [.name, .text] | @csv' content.json`

### Line‑delimited JSON (NDJSON), one row per entity
```shell
jq -c '
  .[]
  | (.Attributes | map({key: .Key, value: .Value}) | from_entries) as $a
  | {
      value: $a.value,
      display: (try ($a["DisplayName - LocalizedLabel"] | fromjson | .LocalizedLabels["1033"].LocalizedLabel) catch null)
    }
' example.json
```

Result:
```json
{"value":970740000,"display":"Incomplete application"}
{"value":970740001,"display":"Submitted"}
```

## Sorting
```json
{
    "changedAttributes": [
        {
            "logicalName": "statecode",
            "oldValue": null,
            "newValue": "0",
            "newName": "Active"
        },
        {
            "logicalName": "resolvebyslastatus",
            "oldValue": null,
            "newValue": "1",
            "newName": "In Progress"
        }
    ]
}
```

jq expression:
```shell
jq '.changedAttributes|=sort_by(.logicalName)' my.json

# or nesting:
# Source - https://stackoverflow.com/a/30332672
# Posted by karlos, modified by community. See post 'Timeline' for change history
# Retrieved 2026-02-17, License - CC BY-SA 4.0

jq '.components.rows|=sort_by(.id)|.components.rows[].properties|=sort_by(.name)' file.json
```

### Reference
[jq cheat sheet](https://developer.zendesk.com/documentation/integration-services/developer-guide/jq-cheat-sheet/)