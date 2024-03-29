| `Account_Expires (now, expire) -> begin 
  if expire < now then "This account has expired." else
    let diff = expire -. now in 
    let duration = 
      if diff < 60. then "in a few seconds" else
	if diff < 3600. then "in a few minutes" else
	  let days = int_of_float (diff /. 86400.) in
	  card "today" "tomorrow" (!! "in %d days") days
    in
    !! "This account will expire %s." duration 
end
| `Account_HereIsYourApiUrl -> "Hello ! Here is your very own private API URL:"
| `Account_ExampleUsage ->"You need to POST a heartbeat in JSON format to this URL."
| `Account_ExampleComment -> "Send a 'this server is alive' heartbeat"
| `Account_ExampleComment2 -> "Panic if 13 minutes pass with no heartbeat"
| `Account_ExampleTest -> "Always test the heartbeat script manually at least once."
| `Account_ExampleCrontab -> "Then, make sure that the heartbeat is sent at regular intervals, such as every five minutes." 
| `Account_RefreshWhenReady -> "When you're done, refresh this page to see your server status."

| `Account_LastSeen (last, now) -> begin 
  let diff = int_of_float (now -. last) in
  if diff < 60 then card "Now" "One second ago" (!! "%d seconds ago") diff else
    let diff = diff / 60 in
    if diff < 60 then card "Seconds ago" "One minute ago" (!! "%d minutes ago") diff else
      if diff < 120 then "An hour ago" else "Hours ago"
end

| `Account_DefaultId -> "(no identifier provided)"

| `Account_Clean -> "Delete inactive"
