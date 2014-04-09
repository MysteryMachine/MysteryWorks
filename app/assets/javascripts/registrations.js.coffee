$(document).ready(()->
  $("input[type=text], input[type=password], input[type=email]").addClass("form-control")
  $('input[type=submit][value="Sign in"]').addClass("align-sign-up")

  headers = $('h2')
  if headers.length > 1
    headers.last().addClass('smaller-h2')
)