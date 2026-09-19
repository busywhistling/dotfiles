function rclone_do
  rclone --stats-log-level NOTICE --stats-one-line --stats=5s --cache-tmp-upload-path="" $argv --filter-from ~/.config/rclone/filters
end
