// Requires jQuery

$(function() {
  var $forms = $('form.blingpass-form');
  var $passFields = $('form.blingpass-form input.blingpass-password');
  var passModels = {};

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
      downStamps: [],
      upStamps: [],
    }
  });

  $passFields.keydown(function(event) {
    var $this = $(this);
    var $obj = passModels[$this.attr('id')];
    var keyCode = event.keyCode;

    if (validKeyCode(keyCode, event.shiftKey, event.ctrlKey, event.altKey, event.metaKey)) {
      $obj.downStamps.push({
        keyCode: keyCode,
        amount: new Date().getTime()
      });
    }
  });

  $passFields.keyup(function(event) {
    var $this = $(this);
    var $obj = passModels[$this.attr('id')];
    var keyCode = event.keyCode;

    if (validKeyCode(keyCode, event.shiftKey, event.ctrlKey, event.altKey, event.metaKey)) {
      $obj.upStamps.push({
        keyCode: keyCode,
        amount: new Date().getTime()
      });
    }

    if ($this.val().length === 0) {
      passModels[$this.attr('id')] = {
        downStamps: [],
        upStamps: []
      }
    }
  });

  $forms.submit(function() {
    var $this = $(this);
    window.setTimeout(function() {
      var json = {};
      $this.children('input').each(function() {
        $each = $(this);
        json[$each.attr('name')] = $each.val();

        if ($each.hasClass('blingpass-password')) {
          var $obj = passModels[$each.attr('id')];

          json.flights = [];
          if ($obj.downStamps.length > 0) {
            json.flights.push(0);
            $obj.downStamps.reduce(function(previous, current, index, array) {
              json.flights.push(current.amount - previous.amount);
              return current;
            });
          }

          json.holds = [];
          var upStamps = $.extend(true, {}, { array: $obj.upStamps });
          upStamps = upStamps.array;
          $obj.downStamps.forEach(function(val) {
            for (var i = 0; i < upStamps.length; i++) {
              if (val.keyCode === upStamps[i].keyCode) {
                json.holds.push(upStamps[i].amount - val.amount);
                upStamps.splice(i, 1);
                break;
              }
            }
          });
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

        window.setTimeout(function() {
          $this.children('.error').removeClass('showing');
        }, 500);
      });

    }, 100);
    return false;
  });
});
