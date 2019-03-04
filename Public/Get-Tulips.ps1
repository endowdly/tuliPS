# -----------------------------------------------------------------------------------------------------------------
# Get-Tulips
# -----------------------------------------------------------------------------------------------------------------

<#
.Synopsis
  Returns the tuliPS configuration hashtable.
.Description
  Returns the tuliPS configuration hashtable. Allows the user to manually interact with tuliPS configuration.   

  Because the tuliPS configuration object is a hashtable, if you copy it and manipulate an entry, you will 
  manipulate the original object. If you are comfortable with hashtables, this is a nice, easy way to change
  tuliPS configuration on the fly.
.Notes
  File extension information is stored as an array of hashtables. This makes dictionary searching easier to code
  and read. However, it can make manipulating the config object by hand a little hard. There are tags added
  for some convenience. 

  Just keep in mind that the extension data is a hashtable[]. 
  This lists of extensions in each hashtable should be stored as a string[]. 
.Example
  PS> Get-Tulips

  The only way to use it.
.Example
  PS>$TuliPSConfig = Get-Tulips
  PS>$TuliPSConfig.File.Directory.ForegroundColor = 'Green'

  Changes the color of a displayed directory to Green. 
.Example
  PS>$TuliPSConfig.File.Extensions.Where{$_.Tag -eq 'Text'}.Extensions += '.json'

  Adds the '.json' file type to an existing extensions set. This example demonstrates how existing 
  extension sets can be filtered and manipulated.
.Example
  PS>$TuliPSConfig.File.Extensions +=
        @{
            Tag = 'MyExts'
            Extensions = '.iso', '.cd'
            ForegroundColor = 'DarkRed'
            BackgroundColor = 'Yellow'
        }

  This example demonstrates how to add an entire extension set by hand. Note the keys, as those SHOULD be
  copied exactly the same to ensure tuliPS can access the set properly. Currently these sets are not validated :(
  Use `Set-Tulips` to ensure extensions sets are proper.
.Inputs
  None
.Outputs
  System.Collections.Hashtable
#>
function Get-Tulips {
    return $Tulips
}