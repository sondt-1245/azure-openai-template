# OpenAI service template

- Open [CloudShell](https://shell.azure.com/)
- Choose `PowerShell`

```shell
New-AzDeployment -Location "japaneast" -TemplateFile ".\main.bicep" -Verbose
```

# Export output to csv

```
jq -r '.stock[] | [.endpoint, .deployment,.key1, .key2] | @csv' output.json
```