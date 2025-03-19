{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.directory-combiner;
in
{
  options.programs.directory-combiner = {
    enable = mkEnableOption "directory combiner utility";
    
    package = mkOption {
      type = types.package;
      default = pkgs.writeShellScriptBin "combine-directory" ''
        #!/usr/bin/env bash
        
        # combine-directory: Recursively combines all files in a directory
        # with headers showing relative paths
        
        set -euo pipefail
        
        if [ $# -lt 1 ]; then
          echo "Usage: combine-directory <directory> [output-file]"
          echo "If output-file is not specified, output goes to stdout"
          exit 1
        fi
        
        TARGET_DIR="$1"
        OUTPUT_FILE=""
        
        if [ $# -ge 2 ]; then
          OUTPUT_FILE="$2"
          # Clear the output file if it exists
          > "$OUTPUT_FILE"
        fi
        
        # Function to process files
        process_files() {
          local dir="$1"
          local rel_path="$2"
          
          # Get all files in the current directory
          find "$dir" -maxdepth 1 -type f | sort | while read -r file; do
            filename=$(basename "$file")
            
            # Create the relative path for the header
            if [ -z "$rel_path" ]; then
              file_rel_path="$filename"
            else
              file_rel_path="$rel_path/$filename"
            fi
            
            # Create a nice header for the file
            header="\n\n========================================\n"
            header+="FILE: $file_rel_path\n"
            header+="========================================\n\n"
            
            # Output the header and file content
            if [ -n "$OUTPUT_FILE" ]; then
              echo -e "$header" >> "$OUTPUT_FILE"
              cat "$file" >> "$OUTPUT_FILE"
            else
              echo -e "$header"
              cat "$file"
            fi
          done
          
          # Process subdirectories recursively
          find "$dir" -maxdepth 1 -type d -not -path "$dir" | sort | while read -r subdir; do
            subdir_name=$(basename "$subdir")
            
            # Create new relative path for subdirectory
            if [ -z "$rel_path" ]; then
              new_rel_path="$subdir_name"
            else
              new_rel_path="$rel_path/$subdir_name"
            fi
            
            # Process the subdirectory
            process_files "$subdir" "$new_rel_path"
          done
        }
        
        # Check if the directory exists
        if [ ! -d "$TARGET_DIR" ]; then
          echo "Error: Directory '$TARGET_DIR' does not exist"
          exit 1
        fi
        
        # Start processing from the root directory
        if [ -n "$OUTPUT_FILE" ]; then
          echo "Combining files from '$TARGET_DIR' into '$OUTPUT_FILE'..."
          process_files "$TARGET_DIR" ""
          echo "Done! Output written to '$OUTPUT_FILE'"
        else
          process_files "$TARGET_DIR" ""
        fi
      '';
      description = "The package providing the directory combiner utility";
    };
    
    extraOptions = mkOption {
      type = types.attrs;
      default = {};
      description = "Extra options to pass to the directory combiner script";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    
    # Create a simple wrapper with documentation
    home.file.".local/share/directory-combiner/README.md".text = ''
      # Directory Combiner
      
      A utility to recursively combine all files in a directory with headers showing relative paths.
      
      ## Usage
      
      ```
      combine-directory <directory> [output-file]
      ```
      
      - If no output file is specified, the combined content is printed to stdout
      - Each file is prefixed with a header showing its relative path from the root directory
      
      ## Example
      
      ```
      combine-directory ~/projects/my-code combined-output.txt
      ```
      
      This will create a file `combined-output.txt` containing all files from `~/projects/my-code` 
      with headers showing their relative paths.
    '';
  };
}
