// Generated by CoffeeScript 1.6.3
var ActionLog, Square, Unit,
  _this = this;

$('button[data-action="move"].btn-action').addClass('active');

$.getJSON('/api/initial-load/', function(data, status) {
  var action_, _i, _len, _ref;
  if (status === 'success') {
    _.extend(_this, data.board_consts);
    _ref = data.actions;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      action_ = _ref[_i];
      _this.add_action(action_);
    }
    _this.account = data.account;
  }
  return _this.board = new board.Board($('.board'));
});

$(document).keydown(function(event) {
  switch (event.which) {
    case 49:
      return _this.set_action('move');
    case 50:
      return _this.set_action('attack');
    case 51:
      return _this.set_action('city');
  }
});

$('.btn-action, .btn-action img').click(function(event) {
  var which;
  if ($(event.target).data('action')) {
    which = $(event.target).data('action');
  } else {
    which = $(event.target).parents('.btn-action').data('action');
  }
  if (which === 'undo') {
    _this.action_log.remove_last_action();
    return $.ajax({
      url: '/api/undo/' + _this.action_log.get_last_action().id + '/',
      method: 'POST',
      dataType: 'json',
      success: function(data) {
        return true;
      },
      error: function(data) {
        alert('Problem saving your action.  The page will now refresh.  Sorry, I should make this more robust sometime.');
        return window.location.href += '';
      }
    });
  } else {
    return _this.set_action(which);
  }
});

({
  set_action: function(action_) {
    var $btn_dom_node;
    console.log('setting action to ' + action_);
    this.current_action = action_;
    $btn_dom_node = $('button[data-action=' + action_ + ']');
    $('.btn-action').not($btn_dom_node).removeClass('active');
    return $btn_dom_node.addClass('active');
  },
  add_action: function(data) {
    var new_action;
    new_action = new action.Action(data);
    this.actions.push(new_action);
    return this.action_log.add(new_action);
  }
});

Unit = (function() {
  function Unit(square, $dom_node, data) {
    this.square = square;
    this.$dom_node = $dom_node;
    _.extend(this, data);
    this.$dom_node.css('background-color', this.owner_color).css('border-bottom-width', (this.amount + 3) / 2).css('margin-top', (-(this.amount + 3) / 2) + 'px').css('height', (22 + this.amount / 2) + 'px');
    this.$dom_node.text(this.amount);
  }

  return Unit;

})();

Square = (function() {
  function Square(sector, $dom_node, data) {
    var $unit_dom_node, i, _i, _ref;
    this.sector = sector;
    this.$dom_node = $dom_node;
    _.extend(this, data);
    if (this.terrain_type === 'water' || this.terrain_type === 'mountains' || this.terrain_type === 'forest') {
      this.$dom_node.find('.subtile').css('background-image', 'url(/static/images/' + this.terrain_type + '-tiles.png)');
      this.$dom_node.find('.north-west').css('background-position', this.get_tile_24_css_offset(this.north_west_tile_24));
      this.$dom_node.find('.north-east').css('background-position', this.get_tile_24_css_offset(this.north_east_tile_24));
      this.$dom_node.find('.south-west').css('background-position', this.get_tile_24_css_offset(this.south_west_tile_24));
      this.$dom_node.find('.south-east').css('background-position', this.get_tile_24_css_offset(this.south_east_tile_24));
    }
    this.$dom_node.css({
      'background-color': '#00aa44'
    });
    this.$dom_node.data('col', this.col).data('row', this.row);
    for (i = _i = 0, _ref = this.units.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      $unit_dom_node = $('<div class="unit"></div>');
      if (i === 0) {
        $unit_dom_node.addClass('first');
      }
      if (i === 1) {
        $unit_dom_node.addClass('second');
      }
      if (i === 2) {
        $unit_dom_node.addClass('third');
      }
      if (i === 3) {
        $unit_dom_node.addClass('fourth');
      }
      if (this.units.length === 1) {
        $unit_dom_node.addClass('one');
      }
      if (this.units.length === 2) {
        $unit_dom_node.addClass('two');
      }
      if (this.units.length === 3) {
        $unit_dom_node.addClass('three');
      }
      if (this.units.length === 4) {
        $unit_dom_node.addClass('four');
      }
      this.$dom_node.append($unit_dom_node);
      this.units[i] = new Unit(this, $unit_dom_node, this.units[i]);
    }
  }

  Square.prototype.get_tile_24_css_offset = function(tile) {
    return (24 * tile % 144 * -1) + 'px ' + (parseInt(24 * tile / 144) * 24 * -1) + 'px';
  };

  return Square;

})();

ActionLog = (function() {
  function ActionLog() {
    this.actions = [];
    this.$dom_node = jQuery('.action-log');
  }

  ActionLog.prototype.add = function(action) {
    var $new_entry;
    this.actions.push(action);
    $new_entry = jQuery('<div class="action-log-entry"></div>');
    $new_entry.text(action.kind);
    return this.$dom_node.append($new_entry);
  };

  ActionLog.prototype.get_last_action = function() {
    return this.actions[this.actions.length - 1];
  };

  ActionLog.prototype.remove_last_action = function() {
    this.$dom_node.find('.action-log-entry:last').remove();
    return this.actions.pop();
  };

  return ActionLog;

})();
