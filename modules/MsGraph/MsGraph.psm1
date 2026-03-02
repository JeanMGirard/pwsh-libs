


$env:MSGRAPH_API = "https://graph.microsoft.com/v1.0"
$env:MSGRAPH_ACCESS_TOKEN = "EwBoBMl6BAAUBKgm8k1UswUNwklmy2v7U/S+1fEAAePfEZOmzNCRvQWbsArz5hSFTa8317lvIQkw9GTj1TAW7LwEuRlyn9uAWBSdmcrjNLTHnETeSTr1xJwP5yjbsQHBgu1qhXeDT17qD+GJzposJB5IWJ5EGqaPNaND29yWg/AmJqfh8yjsaglLBFT87vT2rx/Ihgtk0JZlXAHRV42Q7M0RpFunGMjXRsmLSKpEwDIJTPPvQXeOLZf8gTBjW6+KUDs18VsTm+nuueydO/hRv/dH+xl8Z0+BBZX3m/T5XpDzjnvsO0Z8SRvU0rQv9pj36Yxwoa3nlw+UUT5BpSMgD+OnYh2iTkaE74So5WD2oCigDFpDU3p7FpxVKn0PMXYQZgAAEFn7id09P+j8jQ5Pp4RZ6DYwAxY/JsVPVJW+sgUyFc6oApYXQ7LMzY8IEsssZWP8npuSk7CjYZwhGcFCRVhJ4i8fre/TB3lH17lbHdc1mlpWlcPrOlNqC4brZJV6gJ40isdilMGd5A+havfljDKftbp24oRQyrhx8mRiN61+XKQd8RH0brpKOASfikUY8ZBr1dun//1U41Ip/dJhnVol7c4Th18c9BlnHizhRIITVFoGjQiDz3iy6KIwpymj/L4pN4tKJPgSPFyaULMw1IiDbGjgD7BYcIDwfYz0bY1iR4Dfg8xADTUaX1H53xDG0myVtMQ4NlvZViWEIHcqtnQFhuwK1GZfsDi8mpuLL0b8V3ZfoHFnOvgBuFOxFkfwbJuBaIECCM3nu0T0p/gJfVRIh1MJW3+IG/ECWKTau9Q/ibZSd2xNnQSZaUF88Hjrq0sVb+TAqA47Ty91e86NDVquallk9VWKVQLmiM6JVh3AnjO/L2BsMHmrdhB3csdbYLfthUEnwuPFxZ5ME9AV+tvvh5nQkmGCN0iZLAnEkCOLq+aKU5oZHTM2D8whpvxC3n9DAeoVzeW5iBXqF7vR5v88EqExNIS+wJusbLFZMOjr0KedZy1qdWiYuHWfUcK3vFjIT2WKCThnTmhZUsdbGI9Pu3NqOzwXgI0D1nCF8kZ5BmAiNft6ubOzJFHw8f1sXxxK+CqfxfjGH4tzOCntOcPI6vPUSvD8me6QopjPUrZHCquXgR+0AMtNtZ9DflX6eLNFh2bQAqQTs2LMC+svphdP28tuTKTmeEqU0gqMF9kL9e7VcrJMTxdAb4WYcc7WGhXlcm6KZ5gIfe6WC0pzCMro6hKb5wqNJNg8xjuPwX3W1WpFPMlHZlYowqoGfFTFBdAwI3NNHxcHhBAmM5F8alvGEZEKNzV9fiPyCGEjnwETkb+Sk5zgxjSgxJb5y7GDNrNHQZy3asjJEml9jO7kKBhmXkG7i3k6RYllS9O+6k+pJ/grJdbxHPHLMq3k3pQxWAwRjhe8c7h8lCAL/wYwgUjzhCOaTgazVxs1IVDDVm3rxU+uT80m2AdTnHWRKLCviSyEnAkSC4SY43Km66O9+Yv9brA08GAD"


function Get-MsGraphAccessToken {
  # Get access token
  $body = @{
      client_id     = $clientId
      client_secret = $clientSecret
      scope         = "https://graph.microsoft.com/.default"
      grant_type    = "client_credentials"
  }
  $tokenResponse = Invoke-RestMethod -Method Post -Uri $accessTokenUrl -Body $body
  $env:MSGRAPH_ACCESS_TOKEN = $tokenResponse.access_token
  return $env:MSGRAPH_ACCESS_TOKEN 
}
