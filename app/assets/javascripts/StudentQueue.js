/*
 * StudentQueue.js
 *
 * Defines a class that maintains and updates the state of the queue for Student type users.
 *
 */

function StudentQueue ()
{
  /*----------INSTANCE VARIABLES-------------*/

  this.boardTitle = $('#board_title').val();

  this.user = new User();

  this.interval;

  this.frozen;

  this.active;
  
  this.tas; 

  /*---------INSTANCE METHODS---------------*/

  /**
   * This function initializes event listeners on various buttons in the user interface.
   */
  this.addEventListeners2Queue = function ()
  {
    with (this)
    {
      $('#enter_queue').click(function ()
          {
        if ($(this).attr('value') == 'Enter Queue')
        {
          enterQueue();
        }
        else
        {
          exitQueue();
        }
      });
      
      window.onbeforeunload = function () 
      {
        return "You will be logged out of the queue by navigating away from this page.";
      }
      
      window.onunload = function ()
      {
        signOut();
      }
    }
    
    
    
   
  } 

  /*---------AJAX FUNCTIONS AND THEIR RESPECTIVE CALLBACKS--------*/

  /**
   * This function gets the current state of the queue via AJAX every three seconds.
   * If the request is successful, it calls queryQueueSuccess to handle the data. 
   */
  this.queryQueue = function ()
  {
    with (this)
    {
      $.ajax({
        type : 'GET',
        url : '/boards/' + boardTitle + '/queue',
        headers :
        {
          'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content'),
          'Authorization' : base64_encode(user.getName() + ":" + user.getPassword())
        },
        dataType : 'json',
        success : function (data)
        {
          queryQueueSuccess(data);
        }
      });
    }

    with (this)
    {
      interval = setTimeout(function () { queryQueue(); }, 3000);
    }

  }

  /**
   * This function takes data representing the state of the queue and uses it to update
   * instance variables within the object and call other functions to handle different
   * parts of the queue state data.
   */
  this.queryQueueSuccess = function (data)
  {
    this.active = (data.active.toString() == 'true') ? true : false;
    this.frozen = (data.frozen.toString() == 'true') ? true : false;
    this.tas = data.tas;
    
    if (this.active && !this.frozen) // Active and not frozen
    {
      $('#notification').html('The queue is active. Enter at your convenience.');
      this.updateStudents(data.students);
      this.updateTas(data.tas);
    }
    else if (this.active && this.frozen) // Active but frozen
    {
      $('#notification').html('The queue is active, but no new students may enter.');
      this.updateStudents(data.students);
      this.updateTas(data.tas);
    }
    else if (!this.active) // Not active and frozen
    {
      $('#notification').html('The queue is inactive.');
      this.updateStudents(data.students);
      this.updateTas(data.tas);
    }

    this.updateControlButtons();
    this.updateQueuePosition();
    this.centerControlBar();
  }

  /**
   * This function puts a student into the queue via AJAX. Only applies to users who are
   * students.
   */
  this.enterQueue = function ()
  {
    with (this)
    {
      $.ajax({
        type : 'GET',
        url : '/boards/' + boardTitle + '/queue/enter_queue',
        headers :
        {
          'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content'),
          'Authorization' : base64_encode(user.getName() + ":" + user.getPassword())
        },
        dataType : 'json',
        success : function ()
        {
          enterQueueSuccess();
        }
      });
    }
  }

  this.enterQueueSuccess = function ()
  {
    $('#enter_queue').attr('value','Exit Queue');
    this.centerControlBar();
  }

  /**
   * This function takes a student out of the queue via AJAX. Only applies to users who 
   * are students.
   */
  this.exitQueue = function ()
  {
    with (this)
    {
      $.ajax({
        type : 'GET',
        url : '/boards/' + boardTitle + '/queue/exit_queue',
        headers :
        {
          'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content'),
          'Authorization' : base64_encode(user.getName() + ":" + user.getPassword())
        },
        dataType : 'json',
        success : function ()
        {
          exitQueueSuccess();
        }
      });
    }
  }

  this.exitQueueSuccess = function ()
  {
    with (this)
    {
      $('#queue_list').children().each(function ()
          {
        var studentInfo = $(this).attr('id');

        if (studentInfo.search(user.getName()) != -1)
        {
          $(this).remove();
        }
      });
    }
    
    $('#enter_queue').attr('value','Enter Queue');
    this.centerControlBar();
  }
  
  this.signOut = function ()
  {
    with (this)
    {
      $.ajax({
        type : 'POST',
        url : '/boards/' + boardTitle + '/students/' + user.username,
        headers :
        {
          'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content'),
          'Authorization' : base64_encode(user.getName() + ":" + user.getPassword())
        },
        data :
        {
          _method : 'DELETE',
        },
        dataType : 'json',
        success : function ()
        {
          
        }
      });
    }
  }

  /*--------UTILITY FUNCTIONS-------------------------*/

  this.getDate = function ()
  {
    var d = new Date();
    var date = d.getDate();
    var month = d.getMonth();
    var year = d.getFullYear();
    var dayOfWeek = d.getDay();

    var daysOfWeek = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
    var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    var dateString = daysOfWeek[dayOfWeek] + ' ' + months[month] + ' ' + date + ', ' + year;

    return dateString;
  }

  this.getTime = function ()
  {
    var d = new Date();
    var hour = d.getHours();
    var minute = (d.getMinutes() < 10) ? '0' + d.getMinutes() : d.getMinutes();

    var timeString = '';

    if (hour == 12)
    {
      timeString += hour + ':' + minute + ' pm';
    }
    else if (hour == 0)
    {
      hour = 12;
      timeString += hour + ':' + minute + ' am';
    }
    else if (hour > 12)
    {
      hour = hour - 12;
      timeString += hour + ':' + minute + ' pm';
    }
    else
    {
      timeString += hour + ':' + minute + ' am';
    }

    return timeString;
  }

  this.getQueuePosition = function ()
  {
    var position = -1;
    with (this)
    {
      $('#queue_list').children().each(function ()
          {
        var studentInfo = $(this).attr('id');

        if (studentInfo.split('~~~~')[0] == user.getName())
        {
          position = parseInt(studentInfo.split('~~~~')[1]);

        }
          });
    }
    
    for (var i = 0; i < this.tas.length; i++)
    {    
      try
      {
        if (this.tas[i].student.id == this.user.username)
        {
          position = -2;
          break;
        }
      }
      catch(e)
      {
        continue;
      }
    }

    if (position == -1)
    {
      $('#enter_queue').attr('value','Enter Queue');    
    }

    return position+1;
  }

  /*---------VIEW UPDATE FUNCTIONS---------------------*/

  this.updateControlButtons = function ()
  {
    if (this.active)
    {
      if (this.frozen)
      {
        if ($('#enter_queue').attr('value') == 'Exit Queue')
        {
          $('#enter_queue').show();
          $('#sign_out').removeClass('sign_out_alone');
          $('#sign_out').addClass('sign_out_with');
        }
        else
        {
          $('#enter_queue').hide();
          $('#sign_out').removeClass('sign_out_with');
          $('#sign_out').addClass('sign_out_alone');
        }
      }
      else
      {
        $('#enter_queue').show();
        $('#sign_out').removeClass('sign_out_alone');
        $('#sign_out').addClass('sign_out_with');
      }
    }
    else
    {
      $('#enter_queue').hide();
      $('#sign_out').removeClass('sign_out_with');
      $('#sign_out').addClass('sign_out_alone');
      $('#enter_queue').attr('value','Enter Queue');
    } 
  }

  this.updateQueuePosition = function ()
  {
    var position = '0';

    if (this.getQueuePosition() > 0)
    {
      position = this.getQueuePosition();
    }

    $('.position').html('Queue position: ' + position);
  }

  /**
   * This function takes the data retrieved by queryQueue regarding students in the queue
   * and puts it into the view.
   */
  this.updateStudents = function (a)
  {
    var i;
    var html = '';

    $('#queue_list').html('');
    
    this.updateDateTime();

    for (i = 0; i < a.length; i++)
    {
      html += '<div id="' + a[i].id + '~~~~' + i + '" class="';

      if (i % 2 == 0)
      {
        html += 'even student">';
      }
      else
      {
        html += 'odd student">';
      }

      html += '<p class="username">' + a[i].username + '</p>';
      html += '<p class="location">' + a[i].location + '</p>';
      
      html += '</div>';
    }

    if (i % 2 == 0)
    {
      html += '<div id="queue_bottom" class="even"></div>';
    }
    else
    {
      html += '<div id="queue_bottom" class="odd"></div>';
    }

    $('#queue_list').append(html);
    $('.scroll-pane').jScrollPane();

    with (this)
    {
      $('.student .accept').click(function ()
          {
        var student_id = $(this).parents('.student').attr('id');
        acceptStudent(student_id);
          });

      $('.student .remove').click(function ()
          {
        var student_id = $(this).parents('.student').attr('id');
        removeStudent(student_id);
          });
    }
  }

  this.updateTas = function (a)
  {
    var html = '';

    $('#tas_list').html(html);

    for (var i = 0; i < a.length; i++)
    {
      html += '<div class="post_it">';

      html += '<div class="ta_name">' + a[i].username + '</div>';

      html += '<div class="student_info">';

      if (a[i].student == null)
      {
        html += 'No student';
      }
      else
      {
        html += 'with <strong>' + a[i].student.username + '</strong>';
        html += ' at <strong>' + a[i].student.location + '</strong>';
      }

      html += '</div>';    
      html += '</div>';
    }

    $('#tas_list').append(html);
    $('.scroll-pane').jScrollPane();

  }

  /**
   * This function centers the control panel of buttons at the top of the left panel of
   * the view.
   */
  this.centerControlBar = function ()
  {
    var parentWidth = $('#control_panel').innerWidth();
    var childWidth = $('#control_bar').innerWidth();
    var margin = (parentWidth - childWidth)/2;

    $('#control_bar').css('margin-left',margin + 'px');
  }

  this.updateDateTime = function ()
  {
    var html = '<div id="queue_datetime">';
    html += '<span class="left">' + this.getDate() + '</span>';
    html += '<span class="right">' + this.getTime() + '</span>';
    html += '<div class="clear"></div>';
    html += '</div>';

    $('#queue_list').append(html);
  }  


}
