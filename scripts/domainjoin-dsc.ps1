[CmdletBinding()]
# Incoming Parameters for Script, CloudFormation\SSM Parameters being passed in
param()

# Creating Configuration Data Block that allows plain test password 
# for DSC Configuration Processing
$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName="*"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
        },
        @{
            NodeName = 'localhost'
        }
    )
}

Configuration DomainJoin {

    $ss = ConvertTo-SecureString -String 'stringdoesntmatter' -AsPlaintext -Force
    $Credentials = New-Object PSCredential('${DomainJoinSecrets}', $ss)

    Import-Module -Name PSDesiredStateConfiguration
    Import-Module -Name ComputerManagementDsc
    
    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module ComputerManagementDsc

    Node 'localhost' {

        Computer JoinDomain {
            Name = '{tag:Name}'
            DomainName = '{tag:DomainToJoin}'
            Credential = $Credentials
        }
    }
}

DomainJoin -OutputPath 'D:\Users\aarolima\Documents\PowerShell\MofFiles\DomainJoin' -ConfigurationData $ConfigurationData