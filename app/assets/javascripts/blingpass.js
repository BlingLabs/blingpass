// Requires jQuery

$(function() {
  var $forms = $('form.blingpass-form');
  var $passFields = $('form.blingpass-form input.blingpass-password');
  var passModels = {};
  var keyMap = {};
  var lastHold = 0;
  var lastFlight = 0;

  var validKeyCode = function(keyCode, shiftKey, ctrlKey, altKey, metaKey) {
    var exclude = [91, 92, 93, 37, 38, 39, 40, 45, 46, 36, 35, 33, 34];
    return !metaKey && !ctrlKey && keyCode >= 32 && keyCode <= 126 && exclude.indexOf(keyCode) < 0;
  }

  $passFields.each(function() {
    var $this = $(this);
    if (!$this.attr('id')) {
      $this.attr('id', 'blingpass-password-' + Math.floor(Math.random() * 10000));
    }

    passModels[$this.attr('id')] = {
      holds: [],
      flights: [0]
    }
  });

  $passFields.bind('keydown', function(event) {
    console.log(event.keyCode);
    if (validKeyCode(event.keyCode, event.shiftKey, event.ctrlKey, event.altKey, event.metaKey)) {
      var $this = $(this);
      var $obj = passModels[$this.attr('id')];
      lastHold = new Date();
      keyMap[event.keyCode] = keyMap[event.keyCode] + 1 || 1;

      if (lastFlight) {
        $obj.flights.push((new Date()) - lastFlight);
      }

      console.log('flights: ' + $obj.flights);
      console.log('count flight: ' + $obj.flights.length);
    }
  });

  $passFields.bind('keyup', function(event) {
    var $this = $(this);
    if (keyMap[event.keyCode] && keyMap[event.keyCode] > 0) {
      keyMap[event.keyCode]--;

      var $obj = passModels[$this.attr('id')];
      $obj.holds.push((new Date()) - lastHold);
      lastFlight = new Date();

      console.log('holds: ' + $obj.holds);
      console.log('count holds: ' + $obj.holds.length);
    }

    if ($this.val().length === 0) {
      keyMap = {};
      lastHold = 0;
      lastFlight = 0;
      passModels[$this.attr('id')] = {
        holds: [],
        flights: [0]
      }
    }
  });

  $forms.submit(function() {
    var $this = $(this);
    var json = {};
    $this.children('input').each(function() {
      $each = $(this);
      json[$each.attr('name')] = $each.val();

      if ($each.hasClass('blingpass-password')) {
        $.extend(json, passModels[$each.attr('id')]);
      }
    });

    console.log(json);
    $.post($this.attr('action'), { "user": json }, function(response) {
      if ($this.attr('id').indexOf('register') >= 0) {
        console.log($this.children('.error'));
        $this.children('.error').text(response.status).addClass('showing');
      } else if ($this.attr('id').indexOf('login') >= 0) {
        $this.children('.error').text(response.status).addClass('showing');
      }

      console.log(response);
    });
    return false;
  });
});
