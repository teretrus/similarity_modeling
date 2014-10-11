Param(
  [int32]$old,
  [int32]$new
)

[regex]$regex = "^(?<prefix>((word)|(phoneme))[-])?(?<code>[E][0-9]+[-])?(?<example>[0-9]+)[-](?<person>[0-9]+)[-](?<gender>[fm])[-](?<age>[0-9]+)(?<ext>[.]wav)$";

$files = ls | where { $regex.IsMatch($_.Name) };
$files = $files | where { [int32]::Parse($regex.Match($_.Name).Groups['person']) -eq $old };
[uint]$file_count = ($files | measure).Count;

if ($file_count -eq 0) {
    write-error ([String]::Format("No file found that matches the pattern"))
}
else {
    write-host "";
    write-host ([String]::Format("{0} files found.", $file_count));
    write-host "";

    $files | foreach-object {
        
        $match = $regex.Match($_.Name);
        $new_name = [String]::Format("{0}{1}{2}-{3}-{4}-{5}{6}", $match.Groups['prefix'], $match.Groups['code'], $match.Groups['example'], $new, $match.Groups['gender'], $match.Groups['age'], $match.Groups['ext']);

        write-host ([String]::Format("  {0} --> {1}", $_.Name, $new_name)) -ForegroundColor Gray;

        $new_name = [System.IO.Path]::Combine($_.DirectoryName, $new_name);
    
        move-item $_.FullName $new_name;
    }
    
    write-host "";
    write-host "done!"
    write-host "";
}