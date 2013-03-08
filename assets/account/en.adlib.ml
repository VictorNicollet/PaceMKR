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
