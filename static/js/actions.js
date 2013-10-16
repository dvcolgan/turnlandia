// Generated by CoffeeScript 1.6.3
var Action, ActionManager, BuildCityAction, BuildRoadAction, InitialPlacementAction, MoveAction,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Action = (function() {
  function Action() {}

  Action.prototype.isValid = function() {
    return false;
  };

  Action.prototype.save = function() {
    var actionData;
    actionData = {
      kind: this.kind,
      col: this.col,
      row: this.row,
      move_path: this.movePath
    };
    return $.ajax({
      url: '/api/action/',
      method: 'POST',
      dataType: 'json',
      data: actionData,
      success: function(response) {},
      error: function(response) {
        return alert("Error saving move.  Please check your internet connection and try again: " + (JSON.stringify(response)));
      }
    });
  };

  return Action;

})();

InitialPlacementAction = (function(_super) {
  __extends(InitialPlacementAction, _super);

  function InitialPlacementAction(col, row) {
    this.col = col;
    this.row = row;
    this.kind = 'initial';
    this.name = 'Initial Placement';
  }

  InitialPlacementAction.prototype.isValid = function() {
    return TB.actions.count() < 8 && TB.board.isPassable(this.col, this.row) && TB.board.getUnitCount(this.col, this.row) === 0;
  };

  InitialPlacementAction.prototype.save = function() {
    return InitialPlacementAction.__super__.save.call(this);
  };

  InitialPlacementAction.prototype.draw = function() {};

  return InitialPlacementAction;

})(Action);

MoveAction = (function(_super) {
  __extends(MoveAction, _super);

  MoveAction.prototype.parseMovePath = function(movePath) {
    var coord, moves;
    moves = (function() {
      var _i, _len, _ref, _results;
      _ref = movePath.split('|');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        coord = _ref[_i];
        _results.push(coord.split(','));
      }
      return _results;
    })();
    return _.map(moves, function(coords) {
      return [parseInt(coords[0]), parseInt(coords[1])];
    });
  };

  function MoveAction(col, row, movePath) {
    var i, _i,
      _this = this;
    this.col = col;
    this.row = row;
    this.movePath = movePath;
    this.kind = 'move';
    this.name = 'Move';
    if (this.movePath) {
      this.started = true;
      this.finished = true;
      this.moves = this.parseMovePath(this.movePath);
    } else {
      this.moves = [];
      this.started = false;
      this.finished = false;
      $('.btn-move').addClass('yellow').find('span').text('Move To?');
      this.possibleMoves = new util.Hash2D();
      this.squareTraversalCosts = new util.Hash2D();
      this.possibleMoves.set(this.col, this.row, 0);
      for (i = _i = 1; _i <= 6; i = ++_i) {
        this.possibleMoves.iterateIntKeys(function(col, row, dist) {
          var east, north, south, west;
          if (dist === i - 1) {
            east = TB.board.isPassable(col + 1, row);
            west = TB.board.isPassable(col - 1, row);
            south = TB.board.isPassable(col, row + 1);
            north = TB.board.isPassable(col, row - 1);
            if (east) {
              _this.possibleMoves.set(col + 1, row, i);
            }
            if (west) {
              _this.possibleMoves.set(col - 1, row, i);
            }
            if (south) {
              _this.possibleMoves.set(col, row + 1, i);
            }
            if (north) {
              return _this.possibleMoves.set(col, row - 1, i);
            }
          }
        });
      }
      this.possibleMoves["delete"](this.col, this.row);
      this.possibleMoves.iterateIntKeys(function(col, row, dist) {
        return _this.squareTraversalCosts.set(col, row, TB.board.traversalCost(col, row));
      });
    }
  }

  MoveAction.prototype.save = function() {
    if (this.started === false) {
      return this.started = true;
    } else if (this.finished === false) {
      $('.btn-move').removeClass('yellow').find('span').text('Move Unit');
      this.finished = true;
      this.movePath = this.moves.join('|');
      return MoveAction.__super__.save.call(this);
    }
  };

  MoveAction.prototype.isValid = function() {
    return TB.board.units.get(this.col, this.row) && TB.board.units.get(this.col, this.row).amount > 0 && TB.board.units.get(this.col, this.row).ownerID === TB.myAccount.id;
  };

  MoveAction.prototype.update = function(mouseX, mouseY) {
    var action, _i, _len, _ref, _results;
    TB.mouse.x;
    _ref = this.actions;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      action = _ref[_i];
      if (action.type === 'move') {
        _results.push(action.update(mouseX, mouseY));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  MoveAction.prototype.draw = function() {
    var centerCol, centerRow, err, graph, i, matrix, mouseColDiff, mouseRowDiff, next, nextCol, nextRow, node, path, prev, thisCol, thisRow, _i, _j, _len, _len1, _ref, _ref1, _results,
      _this = this;
    if (!this.finished) {
      this.possibleMoves.iterate(function(col, row) {
        var screenX, screenY;
        screenX = TB.camera.worldColToScreenPosX(col);
        screenY = TB.camera.worldRowToScreenPosY(row);
        TB.ctx.save();
        TB.ctx.fillStyle = 'rgba(255,255,255,0.3)';
        TB.ctx.fillRect(screenX, screenY, TB.camera.zoomedGridSize, TB.camera.zoomedGridSize);
        return TB.ctx.restore();
      });
    }
    if (!this.finished) {
      try {
        centerCol = this.col;
        centerRow = this.row;
        mouseColDiff = TB.activeSquare.col - centerCol;
        mouseRowDiff = TB.activeSquare.row - centerRow;
        matrix = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]];
        this.squareTraversalCosts.iterateIntKeys(function(col, row, cost) {
          return matrix[6 + (col - centerCol)][6 + (row - centerRow)] = cost;
        });
        graph = new Graph(matrix);
        path = astar.search(graph.nodes, graph.nodes[6][6], graph.nodes[6 + mouseColDiff][6 + mouseRowDiff]);
        this.moves = [];
        for (_i = 0, _len = path.length; _i < _len; _i++) {
          node = path[_i];
          this.moves.push([node.x - 6 + centerCol, node.y - 6 + centerRow]);
        }
      } catch (_error) {
        err = _error;
      }
    }
    prev = 'start';
    next = 'end';
    thisCol = this.col;
    thisRow = this.row;
    _ref = this.moves;
    _results = [];
    for (i = _j = 0, _len1 = _ref.length; _j < _len1; i = ++_j) {
      _ref1 = _ref[i], nextCol = _ref1[0], nextRow = _ref1[1];
      if (nextCol > thisCol) {
        next = 'east';
      }
      if (nextCol < thisCol) {
        next = 'west';
      }
      if (nextRow < thisRow) {
        next = 'north';
      }
      if (nextRow > thisRow) {
        next = 'south';
      }
      this.drawArrow(thisCol, thisRow, prev, next);
      if (next === 'north') {
        prev = 'south';
      }
      if (next === 'south') {
        prev = 'north';
      }
      if (next === 'west') {
        prev = 'east';
      }
      if (next === 'east') {
        prev = 'west';
      }
      thisCol = nextCol;
      thisRow = nextRow;
      if (i === this.moves.length - 1) {
        _results.push(this.drawArrow(thisCol, thisRow, prev, 'end'));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  MoveAction.prototype.drawArrow = function(col, row, prev, next) {
    var screenX, screenY, tileX, tileY, _ref;
    screenX = TB.camera.worldColToScreenPosX(col);
    screenY = TB.camera.worldRowToScreenPosY(row);
    _ref = this.getArrowTileOffset(prev, next), tileX = _ref[0], tileY = _ref[1];
    return TB.ctx.drawImage(TB.images.othertilesImage, tileX, tileY, TB.gridSize, TB.gridSize, screenX, screenY, TB.camera.zoomedGridSize, TB.camera.zoomedGridSize);
  };

  MoveAction.prototype.getArrowTileOffset = function(dir1, dir2) {
    if (dir1 === 'west' && dir2 === 'end' || dir1 === 'end' && dir2 === 'west') {
      return [parseInt(TB.gridSize * 0), parseInt(TB.gridSize * 0)];
    }
    if (dir1 === 'south' && dir2 === 'end' || dir1 === 'end' && dir2 === 'south') {
      return [parseInt(TB.gridSize * 1), parseInt(TB.gridSize * 0)];
    }
    if (dir1 === 'east' && dir2 === 'end' || dir1 === 'end' && dir2 === 'east') {
      return [parseInt(TB.gridSize * 2), parseInt(TB.gridSize * 0)];
    }
    if (dir1 === 'north' && dir2 === 'end' || dir1 === 'end' && dir2 === 'north') {
      return [parseInt(TB.gridSize * 3), parseInt(TB.gridSize * 0)];
    }
    if (dir1 === 'south' && dir2 === 'east' || dir1 === 'east' && dir2 === 'south') {
      return [parseInt(TB.gridSize * 0), parseInt(TB.gridSize * 1)];
    }
    if (dir1 === 'north' && dir2 === 'east' || dir1 === 'east' && dir2 === 'north') {
      return [parseInt(TB.gridSize * 1), parseInt(TB.gridSize * 1)];
    }
    if (dir1 === 'west' && dir2 === 'north' || dir1 === 'north' && dir2 === 'west') {
      return [parseInt(TB.gridSize * 2), parseInt(TB.gridSize * 1)];
    }
    if (dir1 === 'west' && dir2 === 'south' || dir1 === 'south' && dir2 === 'west') {
      return [parseInt(TB.gridSize * 3), parseInt(TB.gridSize * 1)];
    }
    if (dir1 === 'start' && dir2 === 'east' || dir1 === 'east' && dir2 === 'start') {
      return [parseInt(TB.gridSize * 0), parseInt(TB.gridSize * 2)];
    }
    if (dir1 === 'start' && dir2 === 'north' || dir1 === 'north' && dir2 === 'start') {
      return [parseInt(TB.gridSize * 1), parseInt(TB.gridSize * 2)];
    }
    if (dir1 === 'start' && dir2 === 'west' || dir1 === 'west' && dir2 === 'start') {
      return [parseInt(TB.gridSize * 2), parseInt(TB.gridSize * 2)];
    }
    if (dir1 === 'start' && dir2 === 'south' || dir1 === 'south' && dir2 === 'start') {
      return [parseInt(TB.gridSize * 3), parseInt(TB.gridSize * 2)];
    }
    if (dir1 === 'start' && dir2 === 'end' || dir1 === 'end' && dir2 === 'start') {
      return [parseInt(TB.gridSize * 0), parseInt(TB.gridSize * 3)];
    }
    if (dir1 === 'west' && dir2 === 'east' || dir1 === 'east' && dir2 === 'west') {
      return [parseInt(TB.gridSize * 1), parseInt(TB.gridSize * 3)];
    }
    if (dir1 === 'north' && dir2 === 'south' || dir1 === 'south' && dir2 === 'north') {
      return [parseInt(TB.gridSize * 2), parseInt(TB.gridSize * 3)];
    }
  };

  return MoveAction;

})(Action);

BuildRoadAction = (function(_super) {
  __extends(BuildRoadAction, _super);

  function BuildRoadAction(col, row) {
    this.col = col;
    this.row = row;
    this.kind = 'road';
    this.name = 'Build Road';
    this.finished = false;
  }

  BuildRoadAction.prototype.isValid = function() {
    var action, _i, _len, _ref;
    console.log(this.col + ' ' + this.row + ' ' + TB.board.getTerrainType(this.col, this.row));
    console.log(TB.myAccount.wood);
    _ref = TB.actions.actions;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      action = _ref[_i];
      if (action.col === this.col && action.row === this.row) {
        return false;
      }
    }
    return TB.myAccount.wood >= 10 && TB.board.isPassable(this.col, this.row);
  };

  BuildRoadAction.prototype.draw = function() {
    var screenX, screenY;
    screenX = TB.camera.worldColToScreenPosX(this.col);
    screenY = TB.camera.worldRowToScreenPosY(this.row);
    TB.ctx.save();
    TB.ctx.fillStyle = 'rgba(0,0,0,0.5)';
    TB.ctx.fillRect(screenX, screenY, TB.camera.zoomedGridSize, TB.camera.zoomedGridSize);
    return TB.ctx.restore();
  };

  return BuildRoadAction;

})(Action);

BuildCityAction = (function(_super) {
  __extends(BuildCityAction, _super);

  function BuildCityAction(col, row) {
    this.col = col;
    this.row = row;
    this.kind = 'city';
    this.name = 'Build city';
  }

  BuildCityAction.prototype.isValid = function() {
    return TB.myAccount.wood >= 10 && TB.board.isPassable(this.col, this.row);
  };

  BuildCityAction.prototype.draw = function() {};

  return BuildCityAction;

})(Action);

ActionManager = (function() {
  function ActionManager() {
    this.actions = [];
  }

  ActionManager.prototype.undo = function() {
    this.actions.pop();
    return $.ajax({
      url: '/api/undo/',
      method: 'POST',
      dataType: 'json',
      success: function(response) {},
      error: function(response) {
        return $('html').text("Error undoing move.  Please check your internet connection and try again: " + (JSON.stringify(response)));
      }
    });
  };

  ActionManager.prototype.cancelMove = function() {
    var action;
    action = _.last(this.actions);
    if (action.kind === 'move' && !action.finished) {
      console.log('canceling');
      this.actions.pop();
      return $('.btn-move').removeClass('yellow').find('span').text('Move Unit');
    } else {
      return console.log(action.kind + ' ' + action.finished);
    }
  };

  ActionManager.prototype.loadFromJSON = function(json) {
    var action, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = json.length; _i < _len; _i++) {
      action = json[_i];
      if (action.kind === 'initial') {
        this.actions.push(new InitialPlacementAction(action.col, action.row));
      }
      if (action.kind === 'move') {
        this.actions.push(new MoveAction(action.col, action.row, action.movePath));
      }
      if (action.kind === 'road') {
        _results.push(this.actions.push(new BuildRoadAction(action.col, action.row)));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  ActionManager.prototype.handleAction = function(kind, col, row) {
    var action;
    console.log(kind);
    if (kind === 'initial') {
      action = new InitialPlacementAction(col, row);
    }
    if (kind === 'move') {
      action = _.last(this.actions);
      if (action) {
        if (action.kind === 'move') {
          action = this.actions.pop();
          if (action.finished) {
            this.actions.push(action);
            action = new MoveAction(col, row);
          }
        } else {
          action = new MoveAction(col, row);
        }
      } else {
        action = new MoveAction(col, row);
      }
    }
    if (kind === 'road') {
      action = new BuildRoadAction(col, row);
    }
    if (kind === 'city') {
      action = new BuildCityAction(col, row);
    }
    if (action.isValid()) {
      action.save();
      return this.actions.push(action);
    } else {
      return console.log('invalid move');
    }
  };

  ActionManager.prototype.count = function() {
    return this.actions.length;
  };

  ActionManager.prototype.draw = function() {
    var action, amount, col, i, initialPlacements, rgb, row, rowData, screenX, screenY, textX, textY, unitRadius, unitX, unitY, _i, _j, _len, _len1, _ref, _ref1, _ref2, _results, _results1;
    TB.ctx.textAlign = 'right';
    TB.fillOutlinedText("This Turn's Actions", TB.camera.width - 16, 24);
    initialPlacements = new util.Hash2D();
    if (!TB.isInitialPlacement) {
      _ref = this.actions;
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        action = _ref[i];
        TB.fillOutlinedText(action.name, TB.camera.width - 16, 24 + i * 24 + 24);
        _results.push(action.draw());
      }
      return _results;
    } else {
      console.log('is initial placement');
      _ref1 = this.actions;
      for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
        action = _ref1[i];
        TB.fillOutlinedText(action.name, TB.camera.width - 16, 24 + i * 24 + 24);
        if (TB.isInitialPlacement) {
          initialPlacements.increment(action.col, action.row);
        }
      }
      _ref2 = initialPlacements.getRaw();
      _results1 = [];
      for (col in _ref2) {
        rowData = _ref2[col];
        _results1.push((function() {
          var _results2;
          _results2 = [];
          for (row in rowData) {
            amount = rowData[row];
            screenX = TB.camera.worldToScreenPosX(col * TB.gridSize);
            screenY = TB.camera.worldToScreenPosY(row * TB.gridSize);
            unitX = screenX + TB.camera.zoomedGridSize / 2;
            unitY = screenY + TB.camera.zoomedGridSize / 2;
            unitRadius = TB.camera.zoomedUnitSize / 2;
            textX = unitX;
            textY = unitY - 3;
            TB.ctx.save();
            TB.ctx.beginPath();
            TB.ctx.fillStyle = 'rgba(0,0,0,0.5)';
            TB.ctx.arc(unitX, unitY, TB.camera.zoomedUnitSize / 2, 0, 2 * Math.PI);
            TB.ctx.fill();
            rgb = util.hexToRGB(TB.myAccount.color);
            TB.ctx.fillStyle = "rgba(" + rgb.r + "," + rgb.g + "," + rgb.b + ",0.5)";
            rgb.r = parseInt(rgb.r * 0.4);
            rgb.g = parseInt(rgb.g * 0.4);
            rgb.b = parseInt(rgb.b * 0.4);
            TB.ctx.strokeStyle = "rgba(" + rgb.r + "," + rgb.g + "," + rgb.b + ",0.5)";
            TB.ctx.lineWidth = 2;
            TB.ctx.beginPath();
            TB.ctx.arc(unitX, unitY - 8, TB.camera.zoomedUnitSize / 2, 0, 2 * Math.PI);
            TB.ctx.fill();
            TB.ctx.stroke();
            TB.ctx.restore();
            TB.ctx.textAlign = 'center';
            _results2.push(TB.fillOutlinedText(amount, textX, textY));
          }
          return _results2;
        })());
      }
      return _results1;
    }
  };

  return ActionManager;

})();
