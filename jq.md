# jq

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