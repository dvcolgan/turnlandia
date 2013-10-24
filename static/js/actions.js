// Generated by CoffeeScript 1.6.3
var Action, ActionManager, BuildCityAction, BuildRoadAction, ClearForestAction, InitialPlacementAction, MoveAction, Overlay, RecruitUnitAction, _ref, _ref1, _ref2, _ref3, _ref4,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Action = (function() {
  function Action(kind, col, row, unitCol, unitRow, movePath) {
    this.kind = kind;
    this.col = col;
    this.row = row;
    this.unitCol = unitCol;
    this.unitRow = unitRow;
    this.movePath = movePath;
  }

  Action.prototype.isValid = function() {
    return false;
  };

  Action.prototype.save = function() {
    var actionData, unit,
      _this = this;
    actionData = {
      kind: this.kind,
      col: this.col,
      row: this.row,
      unit_col: this.unitCol,
      unit_row: this.unitRow,
      move_path: this.movePath
    };
    $.ajax({
      url: '/api/action/',
      method: 'POST',
      dataType: 'json',
      data: actionData,
      success: function(response) {},
      error: function(response) {
        return alert("Error saving move.  Please check your internet connection and try again: " + (JSON.stringify(response)));
      }
    });
    if (kind !== 'initial') {
      unit = TB.board.units.get(this.unitCol, this.unitRow);
      unit.actionsLeft -= 1;
      return unit.actionsLeft;
    } else {

    }
  };

  return Action;

})();

InitialPlacementAction = (function(_super) {
  __extends(InitialPlacementAction, _super);

  function InitialPlacementAction() {
    _ref = InitialPlacementAction.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  InitialPlacementAction.prototype.isValid = function() {
    return TB.actions.count() < 8 && TB.board.isPassable(this.unitCol, this.unitRow) && TB.board.getUnitCount(this.unitCol, this.unitRow) === 0;
  };

  InitialPlacementAction.prototype.save = function() {
    return InitialPlacementAction.__super__.save.call(this);
  };

  InitialPlacementAction.prototype.draw = function() {};

  return InitialPlacementAction;

})(Action);

MoveAction = (function(_super) {
  __extends(MoveAction, _super);

  function MoveAction(kind, col, row, unitCol, unitRow, movePath) {
    this.kind = kind;
    this.col = col;
    this.row = row;
    this.unitCol = unitCol;
    this.unitRow = unitRow;
    this.movePath = movePath;
    if (this.movePath === void 0) {
      this.finished = false;
      this.moves = [];
    } else {
      this.finished = true;
      this.moves = this.parseMovePath(this.movePath);
    }
  }

  MoveAction.prototype.parseMovePath = function(movePath) {
    var coord, moves;
    moves = (function() {
      var _i, _len, _ref1, _results;
      _ref1 = movePath.split('|');
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        coord = _ref1[_i];
        _results.push(coord.split(','));
      }
      return _results;
    })();
    return _.map(moves, function(coords) {
      return [parseInt(coords[0]), parseInt(coords[1])];
    });
  };

  MoveAction.prototype.save = function() {
    this.finished = true;
    this.movePath = this.moves.join('|');
    return MoveAction.__super__.save.call(this);
  };

  MoveAction.prototype.isValid = function() {
    return this.moves.length > 0;
  };

  MoveAction.prototype.draw = function() {
    var centerCol, centerRow, graph, i, matrix, mouseColDiff, mouseRowDiff, next, nextCol, nextRow, node, path, prev, thisCol, thisRow, _i, _j, _len, _len1, _ref1, _ref2, _results,
      _this = this;
    if (!this.finished) {
      try {
        centerCol = this.unitCol;
        centerRow = this.unitRow;
        mouseColDiff = TB.activeSquare.col - centerCol;
        mouseRowDiff = TB.activeSquare.row - centerRow;
        matrix = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]];
        TB.actions.overlay.terrainCosts.iterateIntKeys(function(col, row, cost) {
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
        this.moves = [];
      }
    }
    prev = 'start';
    next = 'end';
    thisCol = this.unitCol;
    thisRow = this.unitRow;
    _ref1 = this.moves;
    _results = [];
    for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
      _ref2 = _ref1[i], nextCol = _ref2[0], nextRow = _ref2[1];
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
    var screenX, screenY, tileX, tileY, _ref1;
    screenX = TB.camera.worldColToScreenPosX(col);
    screenY = TB.camera.worldRowToScreenPosY(row);
    _ref1 = this.getArrowTileOffset(prev, next), tileX = _ref1[0], tileY = _ref1[1];
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

RecruitUnitAction = (function(_super) {
  __extends(RecruitUnitAction, _super);

  function RecruitUnitAction() {
    _ref1 = RecruitUnitAction.__super__.constructor.apply(this, arguments);
    return _ref1;
  }

  RecruitUnitAction.prototype.isValid = function() {
    var action, unit, _i, _len, _ref2;
    _ref2 = TB.actions.actions;
    for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
      action = _ref2[_i];
      if (action.col === this.col && action.row === this.row && action.kind === 'recruit') {
        return false;
      }
    }
    unit = TB.board.units.get(this.col, this.row);
    if (unit === null || unit.ownerID !== TB.myAccount.id) {
      return false;
    }
    if (TB.myAccount.food < 2) {
      return false;
    }
    return true;
  };

  RecruitUnitAction.prototype.draw = function() {
    var screenX, screenY;
    screenX = TB.camera.worldColToScreenPosX(this.col);
    screenY = TB.camera.worldRowToScreenPosY(this.row);
    TB.ctx.save();
    TB.ctx.fillStyle = 'rgba(255,255,255,0.7)';
    TB.ctx.fillRect(screenX, screenY, TB.camera.zoomedGridSize, TB.camera.zoomedGridSize);
    return TB.ctx.restore();
  };

  return RecruitUnitAction;

})(Action);

BuildRoadAction = (function(_super) {
  __extends(BuildRoadAction, _super);

  function BuildRoadAction() {
    _ref2 = BuildRoadAction.__super__.constructor.apply(this, arguments);
    return _ref2;
  }

  BuildRoadAction.prototype.isValid = function() {
    var action, terrainType, _i, _len, _ref3;
    _ref3 = TB.actions.actions;
    for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
      action = _ref3[_i];
      if (action.col === this.col && action.row === this.row && action.kind === 'road') {
        return false;
      }
    }
    terrainType = TB.board.getTerrainType(this.col, this.row);
    if (terrainType !== 'plains') {
      return false;
    }
    if (TB.myAccount.wood < 10) {
      return false;
    }
    if (TB.actions.overlay.positions.get(this.col, this.row) === null) {
      return false;
    }
    return true;
  };

  BuildRoadAction.prototype.draw = function() {
    var screenX, screenY;
    screenX = TB.camera.worldColToScreenPosX(this.col);
    screenY = TB.camera.worldRowToScreenPosY(this.row);
    TB.ctx.save();
    TB.ctx.fillStyle = 'rgba(119,65,27,0.7)';
    TB.ctx.fillRect(screenX, screenY, TB.camera.zoomedGridSize, TB.camera.zoomedGridSize);
    return TB.ctx.restore();
  };

  return BuildRoadAction;

})(Action);

ClearForestAction = (function(_super) {
  __extends(ClearForestAction, _super);

  function ClearForestAction() {
    _ref3 = ClearForestAction.__super__.constructor.apply(this, arguments);
    return _ref3;
  }

  ClearForestAction.prototype.isValid = function() {
    var action, terrainType, _i, _len, _ref4;
    _ref4 = TB.actions.actions;
    for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
      action = _ref4[_i];
      if (action.col === this.col && action.row === this.row && action.kind === 'tree') {
        return false;
      }
    }
    terrainType = TB.board.getTerrainType(this.col, this.row);
    if (terrainType !== 'forest') {
      return false;
    }
    if (TB.actions.overlay.positions.get(this.col, this.row) === null) {
      return false;
    }
    return true;
  };

  ClearForestAction.prototype.draw = function() {
    var screenX, screenY;
    screenX = TB.camera.worldColToScreenPosX(this.col);
    screenY = TB.camera.worldRowToScreenPosY(this.row);
    TB.ctx.save();
    TB.ctx.fillStyle = 'rgba(0,100,0,0.7)';
    TB.ctx.fillRect(screenX, screenY, TB.camera.zoomedGridSize, TB.camera.zoomedGridSize);
    return TB.ctx.restore();
  };

  return ClearForestAction;

})(Action);

BuildCityAction = (function(_super) {
  __extends(BuildCityAction, _super);

  function BuildCityAction() {
    _ref4 = BuildCityAction.__super__.constructor.apply(this, arguments);
    return _ref4;
  }

  BuildCityAction.prototype.isValid = function() {
    return TB.myAccount.wood >= 10 && TB.board.isPassable(this.col, this.row);
  };

  BuildCityAction.prototype.draw = function() {};

  return BuildCityAction;

})(Action);

Overlay = (function() {
  function Overlay(unit, validationFn) {
    var i, lastSquares, possibleMovements, uncheckedSquares, _i,
      _this = this;
    this.positions = new util.Hash2D();
    this.terrainCosts = new util.Hash2D();
    possibleMovements = new util.Hash2D();
    lastSquares = new util.Hash2D();
    lastSquares.set(unit.col, unit.row, 0);
    uncheckedSquares = new util.Hash2D();
    for (i = _i = 1; _i <= 6; i = ++_i) {
      lastSquares.priorityPopAllIntKeys(function(col, row, dist) {
        var prevDist, thisCol, thisRow, traversalCost, _j, _len, _ref5, _ref6, _results;
        _ref5 = [[col + 1, row], [col - 1, row], [col, row + 1], [col, row - 1]];
        _results = [];
        for (_j = 0, _len = _ref5.length; _j < _len; _j++) {
          _ref6 = _ref5[_j], thisCol = _ref6[0], thisRow = _ref6[1];
          if (possibleMovements.get(thisCol, thisRow) === null && TB.board.isPassable(thisCol, thisRow)) {
            traversalCost = TB.board.traversalCost(thisCol, thisRow);
            prevDist = uncheckedSquares.get(thisCol, thisRow, dist + traversalCost);
            if (prevDist === null || prevDist > dist + traversalCost) {
              _results.push(uncheckedSquares.set(thisCol, thisRow, dist + traversalCost));
            } else {
              _results.push(void 0);
            }
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      });
      possibleMovements.concat(uncheckedSquares);
      lastSquares = uncheckedSquares;
      uncheckedSquares = new util.Hash2D();
    }
    possibleMovements.iterateIntKeys(function(thisCol, thisRow, dist) {
      if (validationFn(thisCol, thisRow) && dist <= 6) {
        _this.positions.set(thisCol, thisRow, dist);
        return _this.terrainCosts.set(thisCol, thisRow, TB.board.traversalCost(thisCol, thisRow));
      }
    });
  }

  Overlay.prototype.draw = function(col, row) {
    var screenX, screenY;
    if (this.positions.get(col, row) !== null) {
      screenX = TB.camera.worldColToScreenPosX(col);
      screenY = TB.camera.worldRowToScreenPosY(row);
      TB.ctx.save();
      TB.ctx.fillStyle = 'rgba(255,255,255,0.3)';
      TB.ctx.fillRect(screenX, screenY, TB.camera.zoomedGridSize, TB.camera.zoomedGridSize);
      return TB.ctx.restore();
    }
  };

  return Overlay;

})();

ActionManager = (function() {
  ActionManager.MAPPINGS = {
    'initial': InitialPlacementAction,
    'move': MoveAction,
    'road': BuildRoadAction,
    'tree': ClearForestAction,
    'recruit': RecruitUnitAction
  };

  function ActionManager() {
    this.actions = [];
    this.overlay = null;
    this.moveInProgress = null;
  }

  ActionManager.prototype.unitsActionCount = function(col, row) {
    var action, count, _i, _len, _ref5;
    count = 0;
    _ref5 = this.actions;
    for (_i = 0, _len = _ref5.length; _i < _len; _i++) {
      action = _ref5[_i];
      if (action.unitCol === col && action.unitRow === row) {
        count++;
      }
    }
    return count;
  };

  ActionManager.prototype.createOverlay = function(unit, kind) {
    var fn;
    fn = kind === 'move' ? function(col, row) {
      return TB.board.isPassable(col, row);
    } : kind === 'tree' ? function(col, row) {
      return TB.board.getTerrainType(col, row) === 'forest';
    } : kind === 'road' ? function(col, row) {
      return TB.board.getTerrainType(col, row) === 'plains';
    } : void 0;
    if (fn) {
      return this.overlay = new Overlay(unit, fn);
    }
  };

  ActionManager.prototype.undo = function() {
    var action, unit;
    action = this.actions.pop();
    if (action) {
      unit = TB.board.units.get(action.unitCol, action.unitRow);
      if (unit) {
        unit.actionsLeft++;
      }
      return $.ajax({
        url: '/api/undo/',
        method: 'POST',
        dataType: 'json',
        success: function(response) {},
        error: function(response) {
          return $('html').text("Error undoing move.  Please check your internet connection and try again: " + (JSON.stringify(response)));
        }
      });
    }
  };

  ActionManager.prototype.beginMove = function(col, row) {
    return this.moveInProgress = new MoveAction('move', col, row, col, row);
  };

  ActionManager.prototype.loadFromJSON = function(json) {
    var actionData, action_class, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = json.length; _i < _len; _i++) {
      actionData = json[_i];
      action_class = ActionManager.MAPPINGS[actionData.kind];
      _results.push(this.actions.push(new action_class(actionData.kind, actionData.col, actionData.row, actionData.unitCol, actionData.unitRow, actionData.movePath)));
    }
    return _results;
  };

  ActionManager.prototype.handleAction = function(kind, col, row, unitCol, unitRow) {
    var action, actionsLeft, more;
    action = new ActionManager.MAPPINGS[kind](kind, col, row, unitCol, unitRow);
    if (kind === 'move') {
      action.moves = this.moveInProgress.moves;
    }
    if (action.isValid()) {
      actionsLeft = action.save();
      this.actions.push(action);
      console.log(actionsLeft > 0);
      more = actionsLeft > 0;
    } else {
      more = false;
    }
    if (more) {
      return true;
    } else {
      this.moveInProgress = null;
      this.overlay = null;
      return false;
    }
  };

  ActionManager.prototype.count = function() {
    return this.actions.length;
  };

  ActionManager.prototype.draw = function() {
    var action, amount, col, i, initialPlacements, rgb, row, rowData, screenX, screenY, textX, textY, unitRadius, unitX, unitY, _i, _j, _len, _len1, _ref5, _ref6, _ref7, _results;
    initialPlacements = new util.Hash2D();
    if (!TB.isInitialPlacement) {
      _ref5 = this.actions;
      for (i = _i = 0, _len = _ref5.length; _i < _len; i = ++_i) {
        action = _ref5[i];
        action.draw();
      }
      if (this.moveInProgress) {
        return this.moveInProgress.draw();
      }
    } else {
      _ref6 = this.actions;
      for (i = _j = 0, _len1 = _ref6.length; _j < _len1; i = ++_j) {
        action = _ref6[i];
        if (TB.isInitialPlacement) {
          initialPlacements.increment(action.col, action.row);
        }
      }
      _ref7 = initialPlacements.getRaw();
      _results = [];
      for (col in _ref7) {
        rowData = _ref7[col];
        _results.push((function() {
          var _results1;
          _results1 = [];
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
            _results1.push(TB.fillOutlinedText(amount, textX, textY));
          }
          return _results1;
        })());
      }
      return _results;
    }
  };

  return ActionManager;

})();
