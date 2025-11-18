# Some examples of Azure DevOps pipelines

To create a DevOps pipeline, it is performed by two steps. First, create a pipeline in yaml file and commit to the repo. Then, define a pipeline in the pipeline section of DevOps project.

## az cli
```shell
# list pipelines in the org
az pipelines list -o table
# display the definition of a pipeline in DevOps
az pipelines show --id n
```

## Notes

### `parameters` in yaml file
```yaml
parameters:
- name: environment
  displayName: Targeted a Dynamics/PowerPlatform Environment
  type: string
  default: development
  values:
  - development
  - test
  - uat
  - production
```
This group will be rendered as a dropdown lists on the UI. Each parameter has name and type and etc. The value can be reference in the pipeline yaml by `parameters.NAME`, e.g. `parameters.environment`.

### `variables`
Here, we are talking about the variables defined in pipeline UI. Normally no variables are defined in a standalone pipeline yaml file. The uses are different. These variables give the pipeline flexibility when run from UI. In the UI pipeline definition, one can give them names, if they are allowed to be overridden, if they are secret and default values.

```JSON
"variables": {
    "SolutionName": {
      "allowOverride": true,
      "isSecret": null,
      "value": "DummySolution"
    }
  }
```

In pipeline yaml file, UI variables can be referenced by their names: `$(SolutionName)` or `variables['SolutionName']`. See [example](./use-variables.yml) where those reference types are used.

### Permissions
For pipelines need to write to the repository, in the **Project Settings -> Repos -> Repositories -> Security**, grant `Contribute` permissions: `Allow` to `Build Administrators` **Azure DevOps Group**. *This maybe better done at repo level*.