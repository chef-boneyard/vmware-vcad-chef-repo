name "base"
description "Default run_list for servers."
run_list(
  "recipe[sudo]",
  "recipe[users::sysadmins]"
  )

default_attributes(
  "authorization" => {
    "sudo" => {
      "groups" => ["admin", "wheel", "sysadmin"],
      "users" => ["mray"],
      "passwordless" => true
    }
  }
  )
