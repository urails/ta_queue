/*
 * TAQueue.js
 *
 * Defines a class that maintains and updates the state of the queue for TA type users.
 *
 */

function TAQueue ()
{
  /*----------INSTANCE VARIABLES-------------*/

  this.boardTitle = $('#board_title').val();

  this.user = new User();

  this.interval;

  this.frozen;

  this.active;

  /*---------INSTANCE METHODS---------------*/

  /**
   * This function initializes event listeners on various buttons in the user interface.
   */
  this.addEventListeners2Queue = function ()
  {
    with (this)
    {
      $('#activate_queue').click(function ()
          {
        if ($(this).attr('value') == 'Activate')
        {
          activateQueue(true);
        }
        else
        {
          activateQueue(false);
        }
      });

      $('#freeze_queue').click(function ()
          {
        if ($(this).attr('value') == 'Unfreeze')
        {
          freezeQueue(false);
        }
        else
        {
          freezeQueue(true);
        }
      });
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
    this.centerControlBar();
  }

  /**
   * This function activates the queue via AJAX.
   */
  this.activateQueue = function (isActive)
  {
    with (this)
    {
      $.ajax({
        type : 'POST',
        url : '/boards/' + boardTitle,
        headers :
        {
          'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content'),
          'Authorization' : base64_encode(user.getName() + ":" + user.getPassword())
        },
        data :
        {
          _method : 'PUT',
          'board[active]' : isActive
        },
        dataType : 'json',
        success : function (data,isActive)
        {
          activateQueueSuccess(data,isActive);
        }
      });
    }
  }

  /**
   * This function is a stub.
   */
  this.activateQueueSuccess = function (data,isActive)
  {    
    if (isActive)
    {
      $('#activate_queue').attr('value','Deactivate');
      $('#freeze_queue').show();
    }
    
    if (!isActive)
    {
      $(this).attr('value','Activate');
      $('#freeze_queue').hide();
    }
    
    this.centerControlBar();
  }

  /**
   * This function freezes the queue via AJAX.
   */
  this.freezeQueue = function (isFrozen)
  {
    with (this)
    {
      $.ajax({
        type : 'POST',
        url : '/boards/' + boardTitle + '/queue',
        headers :
        {
          'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content'),
          'Authorization' : base64_encode(user.getName() + ":" + user.getPassword())
        },
        data :
        {
          _method : 'PUT',
          'queue[frozen]' : isFrozen
        },
        dataType : 'json',
        success : function (data,isFrozen)
        {
          freezeQueueSuccess(data,isFrozen);
        }
      });
    }
  }

  /**
   * This is a function stub.
   */
  this.freezeQueueSuccess = function (data,isFrozen)
  {
    if (!isFrozen)
    {
      $('#freeze_queue').attr('value','Freeze');
    }
    
    if (isFrozen)
    {
      $('#freeze_queue').attr('value','Unfreeze');
    }
    
    this.centerControlBar();
  }

  /**
   * This function allows a TA to accept a student from the queue via AJAX. Only applies
   * to users who are TAs.
   */
  this.acceptStudent = function (sid)
  {  
    with (this)
    {
      $.ajax({
        type : 'GET',
        url : '/boards/' + boardTitle + '/students/' + sid.split('~~~~')[0] + '/ta_accept',
        headers :
        {
          'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content'),
          'Authorization' : base64_encode(user.getName() + ":" + user.getPassword())
        },
        dataType : 'json',
        success : function (data)
        {
          acceptStudentSuccess(data);
        }
      });
    }
  }

  this.acceptStudentSuccess = function (data)
  {
    $('#queue_list').children().each(function ()
    {
      var studentInfo = $(this).attr('id');

      if (studentInfo.search(data.id) != -1)
      {
        $(this).remove();
      }
    });
  }

  /**
   * This function allows a TA to remove a student from the queue via AJAX. Only applies
   * to users who are TAs.
   */
  this.removeStudent = function (sid)
  {
    with (this)
    {
      $.ajax({
        type : 'GET',
        url : '/boards/' + boardTitle + '/students/' + sid.split('~~~~')[0] + '/ta_remove',
        headers :
        {
          'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content'),
          'Authorization' : base64_encode(user.getName() + ":" + user.getPassword())
        },
        dataType : 'json',
        success : function (data,textStatus)
        {
          removeStudentSuccess(data,textStatus);
        }
      });
    }
  }

  this.removeStudentSuccess = function (data)
  {
    $('#queue_list').children().each(function ()
        {
      var studentInfo = $(this).attr('id');

      if (studentInfo.search(data.id) != -1)
      {
        $(this).remove();
      }
    });
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

  /*---------VIEW UPDATE FUNCTIONS---------------------*/

  this.updateControlButtons = function ()
  {
    if (this.active)
    {
      $('#activate_queue').attr('value','Deactivate');
      $('#freeze_queue').show();
    }
    else
    {
      $('#activate_queue').attr('value','Activate');
      $('#freeze_queue').hide();
    }

    if (this.frozen)
    {
      $('#freeze_queue').attr('value','Unfreeze');
    }
    else
    {
      $('#freeze_queue').attr('value','Freeze');
    } 
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


      html += '<div class="ta_control">';
      html += '<input type="button" class="accept" value="Accept"/>';
      html += '<input type="button" class="remove" value="Remove"/>';
      html += '</div>';
  

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
        html += 'Current Student: none';
      }
      else
      {
        html += 'Currently with ' + a[i].student.username;
        html += ' at ' + a[i].student.location;
      }

      html += '</div>';
      html += '<div class="ta_status">Status: '

        if (a[i].status == '')
        {
          html += 'None';
        }
        else
        {
          html += a[i].status;
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