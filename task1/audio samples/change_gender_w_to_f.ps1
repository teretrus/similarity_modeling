Param(
  [string]$pattern
)

[regex]$regex = "^(?<word>[E][0-9]+)[-](?<person>[0-9]+)[-](?<gender>[w])[-](?<age>[0-9]+)(?<ext>[.]wav)$";

$files = ls ($pattern) | where { $regex.IsMatch($_.Name) };
[uint]$file_count = ($files | measure).Count;

if ($file_count -eq 0) {
    write-error ([String]::Format("No file found that matches the pattern '{0}'", $pattern))
}
else {
    write-host "";
    write-host ([String]::Format("{0} files found.", $file_count));
    write-host "";

    $files | foreach-object {
        
        $match = $regex.Match($_.Name);
        $new_name = [String]::Format("{0}-1-{1}-{2}-{3}{4}", $match.Groups['word'], $match.Groups['person'], 'f', $match.Groups['age'], $match.Groups['ext']);

        write-host ([String]::Format("  {0} --> {1}", $_.Name, $new_name)) -ForegroundColor Gray;

        $new_name = [System.IO.Path]::Combine($_.DirectoryName, $new_name);
    
        move-item $_.FullName $new_name;
    }
    
    write-host "";
    write-host "done!"
    write-host "";
}