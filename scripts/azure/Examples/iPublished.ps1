az ad sp list | ConvertFrom-Json  | foreach-object { $_ } | Where-Object  {$_.publisherName -match "Dimgo Technologies" }
