name "database"
description "MySQL role."
run_list(
  "recipe[mysql::server]",
  "recipe[demo-app::mysql]"
  )
