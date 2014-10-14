[regex]$regex = "^((?<prefix>(phoneme)|(word))[-](?<code>[E][0-9]+)[-])?(?<example>[0-9]+)[-](?<person>[0-9]+)[-](?<gender>[fm])[-](?<age>[0-9]+)(?<ext>[.]wav)$";

$files = ls | where { $regex.IsMatch($_.Name) };
[uint]$file_count = ($files | measure).Count;

if ($file_count -eq 0) {
    write-error ([String]::Format("No files found."))
}
else {
    
    $matches = $files | select-object -property @{Name="Match"; Expression = {$regex.Match($_.Name)}};
    
    $matches = $matches | select-object -property  @{Name="Prefix";  Expression = {$_.Match.Groups["prefix"].Value}} `
                                                  ,@{Name="Code";    Expression = {$_.Match.Groups["code"].Value}} `
                                                  ,@{Name="Example"; Expression = {$_.Match.Groups["example"].Value}} `
                                                  ,@{Name="Person";  Expression = {$_.Match.Groups["person"].Value}} `
                                                  ,@{Name="Gender";  Expression = {$_.Match.Groups["gender"].Value}} `
                                                  ,@{Name="Age";     Expression = {$_.Match.Groups["age"].Value}};

    $people = $matches | group-object Person | select-object -ExpandProperty Name;
    $codes = $matches | where { ($_.Prefix -eq "word") -or ($_.Prefix -eq "phoneme") } | group-object Code | select-object -ExpandProperty Name;

    
    write-host "";
    write-host ([String]::Format("    {0} people found: {1}", ($people |measure).Count, [String]::Join(", ", $people))) -ForegroundColor gray;
    write-host ([String]::Format("    {0} codes found: {1} ..", ($codes |measure).Count, [String]::Join(", ", ($codes | select-object -first 10)))) -ForegroundColor gray;

    write-host "";
    write-host "    checking words:";

    $missing = $matches  | where { $_.Prefix -eq "word" } `                         | group-object Person `                         | select-object -property "Name", `                                                   @{Name="Missing";  Expression = { `
                                                                                        $person_codes = $_.Group | select-object -ExpandProperty Code;
                                                                                        return $codes | where {-not ($person_codes -contains $_) }; `                                                                                   }} `
                         | where { -not (($_.Missing | measure).count -eq 0) } `
                         | select-object -property "Name", `                                                   @{Name="Missing";  Expression = { `
                                                                                        [String]::Join(", ", $_.Missing) `                                                                                   }};
    if (($missing | measure).Count -eq 0){
        write-host "        all ok!" -ForegroundColor Green;
    }
    else{
        $missing | foreach-object {
            write-host ([String]::Format("        person {0} is missing: {1}", $_.Name, $_.Missing)) -ForegroundColor red
        }
    }


    write-host "";
    write-host "    checking phonemes:";

    $missing = $matches  | where { $_.Prefix -eq "phoneme" } `                         | group-object Person `                         | select-object -property "Name", `                                                   @{Name="Missing";  Expression = { `
                                                                                        $person_codes = $_.Group | select-object -ExpandProperty Code;
                                                                                        return $codes | where {-not ($person_codes -contains $_) }; `                                                                                   }} `
                         | where { -not (($_.Missing | measure).count -eq 0) } `
                         | select-object -property "Name", `                                                   @{Name="Missing";  Expression = { `
                                                                                        [String]::Join(", ", $_.Missing) `                                                                                   }};
    if (($missing | measure).Count -eq 0){
        write-host "        all ok!" -ForegroundColor Green;
    }
    else{
        $missing | foreach-object {
            write-host ([String]::Format("        person {0} is missing: {1}", $_.Name, $_.Missing)) -ForegroundColor red
        }
    }
}