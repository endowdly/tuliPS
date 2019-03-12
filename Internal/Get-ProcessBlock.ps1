# -----------------------------------------------------------------------------------------------------------------
# Get-ProcessBlock
# -----------------------------------------------------------------------------------------------------------------

<#
.Synopsis
  This function converts the module variable TypeTracker into a unified ScriptBlock.
.Description
  This function converts the module variable TypeTracker into a unified ScriptBlock for use in Invoke-Wrapper.

  It converts a hashtable of type keys and scriptblock values into a scriptblock with internal conditionals. 
  The hashtable prevents multiple scriptblocks acting on the same type (which would be bad). 
.Inputs
  None
.Outputs 
  Scriptblock
.Example 
   PS> Get-ProcessBlock
   The only way to use it.
#>
function Get-ProcessBlock {
    [CmdletBinding()]
    param ()

    begin {
        
        
        # Fetch the module variable holding our type data and scriptblocks.
        # unit -> DictionaryEntry 
        function GetTypeTracker {
            $script:TypeTracker.GetEnumerator()
        }


        # Turn an enumerated hashtable into a string array that is our formatting block.
        # DictionaryEntry -> string[]
        filter ConvertToStringArray { 
            @(
                'if ($_ -is [{0}]) {{' -f $_.Key.ToString()
                $_.Value.ToString()
                '$_ = $null'
                '}'
            )
        }


        # Jam the pipeline and sequence the strings into a stringbuilder.
        # string[] -> StringBuilder
        function AddStringToStringBuilder ($sb) {

            foreach ($s in $input) {
                [void] $sb.AppendLine($s)
            }

            $sb
        }


        # Take any object and invoke its ToString method.
        # obj -> string
        filter ConvertToString {
            $_.ToString() 
        }


        # Take a string and make a scriptblock from it.
        # The create method implicitly tries to call ToString on objects to get a string.
        # obj -> scriptblock
        filter ConvertToScriptblock {
            [scriptblock]::Create($_) 
        }

        $tmp = [System.Text.StringBuilder]::new($NewProcess)
    }

    end {
        GetTypeTracker |
            ConvertToStringArray |
            AddStringToStringBuilder $tmp | 
            ConvertToScriptblock 
    }
}