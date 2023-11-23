# OpenAI service template

- Open [CloudShell](https://shell.azure.com/)
- Choose `PowerShell`

```shell
New-AzDeployment -Location "japaneast" -TemplateFile ".\main.bicep" -Verbose
```