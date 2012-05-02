$( ->
  $.ajaxSetup {
    headers :
      'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content'),
      'Authorization' : base64_encode(window.user_id + ":" + window.user_token)
  }
)
