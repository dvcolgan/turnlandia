// Generated by CoffeeScript 1.6.3
var Board;

Board = (function() {
  function Board() {
    this.squares = new util.Hash2D();
  }

  Board.prototype.placeUnitOnSquare = function(col, row, ownerID) {
    return this.squares.get(col, row).placeUnit(ownerID);
  };

  Board.prototype.addSquare = function(square) {
    return this.squares.set(square.col, square.row, new Square(square));
  };

  Board.prototype.draw = function() {
    var col, endCol, endRow, row, startCol, startRow, thisSquare, _i, _results;
    TB.ctx.textAlign = 'center';
    TB.ctx.fillStyle = '#148743';
    TB.ctx.fillRect(0, 0, TB.camera.width, TB.camera.height);
    TB.ctx.lineWidth = 1;
    startCol = Math.floor(TB.camera.x / TB.camera.zoomedGridSize);
    startRow = Math.floor(TB.camera.y / TB.camera.zoomedGridSize);
    endCol = startCol + Math.ceil(TB.camera.width / TB.camera.zoomedGridSize);
    endRow = startRow + Math.ceil(TB.camera.height / TB.camera.zoomedGridSize);
    _results = [];
    for (row = _i = startRow; startRow <= endRow ? _i <= endRow : _i >= endRow; row = startRow <= endRow ? ++_i : --_i) {
      _results.push((function() {
        var _j, _results1;
        _results1 = [];
        for (col = _j = startCol; startCol <= endCol ? _j <= endCol : _j >= endCol; col = startCol <= endCol ? ++_j : --_j) {
          thisSquare = this.squares.get(col, row);
          if (thisSquare) {
            _results1.push(thisSquare.draw());
          } else {
            _results1.push(void 0);
          }
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  return Board;

})();
