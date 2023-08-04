[CmdletBinding()]
# Incoming Parameters for Script, CloudFormation\SSM Parameters being passed in
param()

# Creating Configuration Data Block that has the Certificate Information for DSC Configuration Processing
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

Configuration WebsiteTest {

    # Import the module that contains the resources we're using.
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    # The Node statement specifies which targets this configuration will be applied to.
    Node 'localhost' {
        
        # The first resource block ensures that the Web-Server (IIS) feature is enabled.
        WindowsFeature WebServer {
            Ensure = "Present"
            Name   = "Web-Server"
        }

        Script GetWebFiles {
            GetScript = {
                $filelocation = "c:\webfiles\index.htm"
                Return @{Result = [string]$(test-path $filelocation)}
            }
            TestScript = {
                $filelocation = "c:\webfiles\index.htm"
                if((test-path $filelocation) -eq $false) {
                    Write-Verbose 'Files need to be Downloaded'
                    Return $false
                } else {
                    Write-Verbose 'Files are present locally'
                    Return $true
                }
            }
            SetScript = {
                Copy-S3Object -Bucket '{ssm:webfilebucket}' -key index.htm -LocalFile c:\inetpub\wwwroot\index.htm
            }
            DependsOn = '[WindowsFeature]WebServer'
        }
    }
}

WebsiteTest -OutputPath 'D:\Users\aarolima\Documents\PowerShell\MofFiles\WebsiteTest' -ConfigurationData $ConfigurationData