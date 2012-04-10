$( ->
  $.ajaxSetup {
    headers :
      'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content'),
      'Authorization' : base64_encode($("#user_id").val() + ":" + $("#user_token").val())
  }
)
