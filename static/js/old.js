// Generated by CoffeeScript 1.6.3
var Board, Sector;

Sector = (function() {
  function Sector(board, $dom_node, x, y) {
    var first_square_x, first_square_y,
      _this = this;
    this.board = board;
    this.$dom_node = $dom_node;
    this.x = x;
    this.y = y;
    this.squares = {};
    this.$dom_node.css('left', (this.x * TB.sector_size * TB.grid_size - this.board.scroll.x) + 'px').css('top', (this.y * TB.sector_size * TB.grid_size - this.board.scroll.y) + 'px');
    first_square_x = this.x * TB.sector_size;
    first_square_y = this.y * TB.sector_size;
    $.getJSON('/api/sector/' + first_square_x + '/' + first_square_y + '/' + TB.sector_size + '/' + TB.sector_size + '/', function(data, status) {
      var $square_dom_node, action, dest_in, i, new_square, square_data, src_in, _i, _j, _len, _len1, _ref, _results;
      if (status === 'success') {
        for (i = _i = 0, _len = data.length; _i < _len; i = ++_i) {
          square_data = data[i];
          $square_dom_node = $('<div class="grid-square">\
                                            <div class="subtile north-west"></div>\
                                            <div class="subtile north-east"></div>\
                                            <div class="subtile south-west"></div>\
                                            <div class="subtile south-east"></div>\
                                        </div>');
          $square_dom_node.css('left', parseInt((i % TB.sector_size) * TB.grid_size) + 'px').css('top', parseInt(Math.floor(i / TB.sector_size) * TB.grid_size) + 'px');
          _this.$dom_node.append($square_dom_node);
          if (!(square_data.col in _this.squares)) {
            _this.squares[square_data.col] = {};
          }
          if (!(square_data.col in _this.board.squares)) {
            _this.board.squares[square_data.col] = {};
          }
          new_square = new Square(_this, $square_dom_node, square_data);
          _this.board.squares[square_data.col][square_data.row] = new_square;
          _this.squares[square_data.col][square_data.row] = new_square;
        }
        _ref = TB.actions;
        _results = [];
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          action = _ref[_j];
          src_in = _this.contains_square(action.src_col, action.src_row);
          dest_in = _this.contains_square(action.dest_col, action.dest_row);
          if (src_in && dest_in) {
            _results.push(_this.board.draw_arrow(_this.board.squares[action.src_col][action.src_row], _this.board.squares[action.dest_col][action.dest_row]));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      } else {
        return alert(JSON.stringify(data));
      }
    });
  }

  Sector.prototype.show = function() {};

  Sector.prototype.hide = function() {};

  Sector.prototype.contains_square = function(col, row) {
    return col >= this.x * TB.sector_size && row >= this.y * TB.sector_size && col < this.x * TB.sector_size + TB.sector_size && row < this.y * TB.sector_size + TB.sector_size;
  };

  return Sector;

})();

Board = (function() {
  function Board($dom_node, board_consts) {
    var _this = this;
    this.$dom_node = $dom_node;
    _.extend(this, board_consts);
    this.scroll = {
      x: 0,
      y: 0
    };
    this.max_depth = 6;
    this.scroll.x = -this.get_view_width() / 2;
    this.scroll.y = -this.get_view_height() / 2;
    this.sectors = {};
    this.squares = {};
    this.active_square = null;
    this.is_moving = null;
    this.move_start_square = null;
    this.$dom_node.on('click', '.grid-square', function(event) {
      var $square_dom_node, col, end, graph, node, result, row, skip, square_traversal_costs, start, total_cost, _i, _j, _k, _l, _len, _len1, _ref, _ref1;
      if (!(Math.abs(_this.last_scroll.x - _this.scroll.x) < 5 && Math.abs(_this.last_scroll.y - _this.scroll.y) < 5)) {
        console.log('ignoring click');
        return;
      }
      console.log(TB.current_action);
      if (TB.current_action === 'road') {
        $.ajax({
          url: '/api/action/road/' + 1 + '/' + _this.active_square.col + '/' + _this.active_square.row + '/',
          method: 'POST',
          dataType: 'json',
          success: function(data) {
            return true;
          }
        });
      } else if (TB.current_action === 'move') {
        if (!_this.is_moving) {
          _this.move_start_square = _this.active_square;
          _this.is_moving = true;
          square_traversal_costs = _this.get_square_traversal_costs(_this.move_start_square.col, _this.move_start_square.row, _this.max_depth);
          $('.reachable-square').removeClass('reachable-square');
          graph = new astar.Graph(square_traversal_costs);
          for (col = _i = 0, _ref = _this.max_depth * 2; 0 <= _ref ? _i <= _ref : _i >= _ref; col = 0 <= _ref ? ++_i : --_i) {
            for (row = _j = 0, _ref1 = _this.max_depth * 2; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; row = 0 <= _ref1 ? ++_j : --_j) {
              start = graph.nodes[_this.max_depth][_this.max_depth];
              end = graph.nodes[col][row];
              console.log('start ' + start.x + ' ' + start.y + ', end ' + end.x + ' ' + end.y);
              result = astar.astar.search(graph.nodes, start, end);
              total_cost = 0;
              skip = false;
              for (_k = 0, _len = result.length; _k < _len; _k++) {
                node = result[_k];
                if (node.cost === 0) {
                  skip = true;
                }
                total_cost += node.cost;
                if (total_cost > _this.max_depth) {
                  skip = true;
                }
              }
              if (skip) {
                continue;
              }
              for (_l = 0, _len1 = result.length; _l < _len1; _l++) {
                node = result[_l];
                $square_dom_node = _this.squares[(_this.move_start_square.col - _this.max_depth) + col][(_this.move_start_square.row - _this.max_depth) + row].$dom_node;
                $square_dom_node.addClass('reachable-square');
              }
            }
          }
        } else {
          console.log('move done');
          _this.is_moving = false;
          $('.reachable-square').removeClass('reachable-square');
          $.ajax({
            url: '/api/action/move/' + _this.move_start_square.col + '/' + _this.move_start_square.row + '/' + _this.active_square.col + '/' + _this.active_square.row + '/',
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
        }
      }
    });
    $(document).keydown(function(event) {
      _this.is_moving = false;
      return true;
    });
    this.$dom_node.on('mouseenter', '.grid-square', function(event) {
      var $square_dom_node, previous_active_square;
      if (!$(event.target).hasClass('grid-square')) {
        $square_dom_node = $(event.target).parents('.grid-square');
      } else {
        $square_dom_node = $(event.target);
      }
      previous_active_square = _this.active_square;
      _this.active_square = _this.squares[$square_dom_node.data('col')][$square_dom_node.data('row')];
      if (_this.is_moving && previous_active_square !== _this.active_square) {
        return _this.draw_arrow(_this.move_start_square, _this.active_square);
      }
    });
  }

  Board.prototype.draw_arrow = function(start_square, end_square) {
    var $square_dom_node, dx, dy, end, graph, last_direction, last_node, next_direction, node, result, square_traversal_costs, start, total_cost, _i, _j, _len, _len1;
    square_traversal_costs = this.get_square_traversal_costs(start_square.col, start_square.row, this.max_depth);
    graph = new astar.Graph(square_traversal_costs);
    start = graph.nodes[this.max_depth][this.max_depth];
    end = graph.nodes[(end_square.col - start_square.col) + this.max_depth][(end_square.row - start_square.row) + this.max_depth];
    result = astar.astar.search(graph.nodes, start, end);
    $('.arrow.unit-' + start_square.units[0].id).remove();
    if (result[0].x === this.max_depth) {
      if (result[0].y > this.max_depth) {
        next_direction = 'south';
      }
      if (result[0].y < this.max_depth) {
        next_direction = 'north';
      }
    }
    if (result[0].y === this.max_depth) {
      if (result[0].x > 0) {
        next_direction = 'west';
      }
      if (result[0].x < 0) {
        next_direction = 'east';
      }
    }
    last_direction = 'start';
    last_node = {
      x: this.max_depth,
      y: this.max_depth
    };
    total_cost = 0;
    for (_i = 0, _len = result.length; _i < _len; _i++) {
      node = result[_i];
      if (node.cost === 0) {
        return;
      }
      total_cost += node.cost;
      if (total_cost > this.max_depth) {
        return;
      }
    }
    for (_j = 0, _len1 = result.length; _j < _len1; _j++) {
      node = result[_j];
      dx = node.x - last_node.x;
      dy = node.y - last_node.y;
      if (node.x === last_node.x) {
        if (dy > 0) {
          next_direction = 'south';
        }
        if (dy < 0) {
          next_direction = 'north';
        }
      }
      if (node.y === last_node.y) {
        if (dx > 0) {
          next_direction = 'east';
        }
        if (dx < 0) {
          next_direction = 'west';
        }
      }
      $square_dom_node = this.squares[start_square.col + (last_node.x - this.max_depth)][start_square.row + (last_node.y - this.max_depth)].$dom_node;
      $square_dom_node.prepend($('<div class="arrow ' + last_direction + '-' + next_direction + ' unit-' + start_square.units[0].id + '"></div>'));
      last_node = node;
      if (next_direction === 'north') {
        last_direction = 'south';
      }
      if (next_direction === 'south') {
        last_direction = 'north';
      }
      if (next_direction === 'east') {
        last_direction = 'west';
      }
      if (next_direction === 'west') {
        last_direction = 'east';
      }
    }
    $square_dom_node = this.squares[start_square.col + (last_node.x - this.max_depth)][start_square.row + (last_node.y - this.max_depth)].$dom_node;
    $square_dom_node.prepend($('<div class="arrow ' + last_direction + '-end unit-' + start_square.units[0].id + '"></div>'));
    return console.log('done');
  };

  Board.prototype.get_square_traversal_costs = function(x, y, radius) {
    var col, row, square_traversal_costs, traversal_row, _i, _j, _ref, _ref1, _ref2, _ref3;
    square_traversal_costs = [];
    for (col = _i = _ref = x - radius, _ref1 = x + radius; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; col = _ref <= _ref1 ? ++_i : --_i) {
      traversal_row = [];
      for (row = _j = _ref2 = y - radius, _ref3 = y + radius; _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; row = _ref2 <= _ref3 ? ++_j : --_j) {
        traversal_row.push(this.squares[col][row].traversal_cost);
      }
      square_traversal_costs.push(traversal_row);
    }
    return square_traversal_costs;
  };

  return Board;

})();