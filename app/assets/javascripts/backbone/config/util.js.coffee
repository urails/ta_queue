class Util
  getTime: ->
    d = new Date()
    hour = d.getHours()
    minute = d.getMinutes()

    if (d.getMinutes() < 10)
      minute = '0' + minute
    
    timeString = ''
    
    if (hour == 12)
      timeString += hour + ':' + minute + ' pm'
    else if (hour == 0)
      hour = 12
      timeString += hour + ':' + minute + ' am'
    else if (hour > 12)
      hour = hour - 12
      timeString += hour + ':' + minute + ' pm'
    else
      timeString += hour + ':' + minute + ' am'
    
    return timeString
    
  getDate: ->
    d = new Date()
    date = d.getDate()
    month = d.getMonth()
    year = d.getFullYear()
    dayOfWeek = d.getDay()
    
    daysOfWeek = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
    months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
    
    dateString = daysOfWeek[dayOfWeek] + ' ' + months[month] + ' ' + date + ', ' + year
    
    return dateString

# Allows a util object to be available in the global namespace through window
window.util = new Util
