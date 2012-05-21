toggle_student_login = ->
  $('#ta_panel').hide()
  $('#student_panel').show()
  $('#student_tab').addClass('active')
  $('#ta_tab').removeClass('active')

toggle_ta_login = ->
  $('#ta_panel').show()
  $('#student_panel').hide()
  $('#student_tab').removeClass('active')
  $('#ta_tab').addClass('active')

$ ->
  if window.location.search == '?ta=true'
    toggle_ta_login()
  else
    toggle_student_login()
  
  # TA tab/panel and student tab/panel toggle
  $('#student_tab, #ta_tab')
    .click ->
      if $(this).attr('id') == 'student_tab' && $('#student_panel').css('display') == 'none'
        toggle_student_login()
      
      if $(this).attr('id') == 'ta_tab' && $('#ta_panel').css('display') == 'none'
        toggle_ta_login()
  

  return null
