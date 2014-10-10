Param(
  [string]$title
)

$pattern = [String]::Format("{0}--*", $title);
$files = ls ($pattern);

$file_count = ($files | measure).Count;

if ($file_count -eq 0) {
    write-error [String]::Format("No file found that matches the pattern '{0}'", $pattern)
}
else {
    write-host "";
    write-host ([String]::Format("{0} files found.", $file_count));
    write-host "";

    $files | foreach-object {
        $number = $_.BaseName.Substring($pattern.Length-1);

        $new_name = [String]::Format("E{0}-{1}{2}",$number, $title, $_.Extension);

        write-host ([String]::Format("  {0} --> {1}", $_.Name, $new_name)) -ForegroundColor Gray;

        $new_name = [System.IO.Path]::Combine($_.DirectoryName, $new_name);
    
        move-item $_.FullName $new_name;
    }
    
    write-host "";
    write-host "done!"
    write-host "";
}