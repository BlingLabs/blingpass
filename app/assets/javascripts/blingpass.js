// Requires jQuery

$(function() {
  var $forms = $('form.blingpass-form');
  var $passFields = $('form.blingpass-form input.blingpass-password');
  var passModels = {};
  var lastKey = 0;
  var lastHold = 0;
  var lastFlight = 0;

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
    var $this = $(this);
    var $obj = passModels[$this.attr('id')];
    lastHold = new Date();
    lastKey = event.keyCode;

    if (lastFlight) {
      $obj.flights.push((new Date()) - lastFlight);
    }

    console.log('flights: ' + $obj.flights);
    console.log('flights count: ' + $obj.flights.length);
  });

  $passFields.bind('keyup', function(event) {
    var $this = $(this);
    var $obj = passModels[$this.attr('id')];
    $obj.holds.push((new Date()) - lastHold);
    lastFlight = new Date();

    console.log('holds: ' + $obj.holds);
    console.log('count holds: ' + $obj.holds.length);
  });

  $forms.submit(function() {
    var $this = $(this);
    var json = {};
    $this.children('input').each(function() {
      $each = $(this);
      json[$each.attr('name')] = $each.text();

      if ($each.hasClass('blingpass-password')) {
        $.extend(json, passModels[$each.attr('id')]);
      }
    });

    console.log(json);
    return false;
  });
});
