// Generated by CoffeeScript 1.6.3
var Board;

Board = (function() {
  function Board(selector) {
    var resizeBoard,
      _this = this;
    this.selector = selector;
    this.scroll = {
      x: 0,
      y: 0
    };
    this.lastMouse = {
      x: 0,
      y: 0
    };
    this.lastScroll = {
      x: 0,
      y: 0
    };
    this.dragging = false;
    this.gridSize = 48;
    this.sectorSize = 10;
    this.squareData = new Hash2D();
    this.squareDomNodes = new Hash2D();
    this.sectorData = new Hash2D();
    this.sectorDomNodes = new Hash2D();
    $(this.selector).mousedown(function(event) {
      event.preventDefault();
      _this.lastMouse = {
        x: event.clientX,
        y: event.clientY
      };
      _this.lastScroll.x = _this.scroll.x;
      _this.lastScroll.y = _this.scroll.y;
      return _this.dragging = true;
    });
    $(this.selector).mousemove(function(event) {
      if (_this.dragging) {
        event.preventDefault();
        _this.scroll.x = _this.lastScroll.x - (event.clientX - _this.lastMouse.x);
        _this.scroll.y = _this.lastScroll.y - (event.clientY - _this.lastMouse.y);
        return _this.loadSectorsOnScreen();
      }
    });
    $(document).mouseup(function(event) {
      return _this.dragging = false;
    });
    resizeBoard = function() {
      $(_this.selector).width(_this.getViewWidth()).height(_this.getViewHeight());
      return $(window).resize(resizeBoard);
    };
    resizeBoard();
  }

  Board.prototype.getViewWidth = function() {
    return $(window).width() - (48 + 20) - 160;
  };

  Board.prototype.getViewHeight = function() {
    return $(window).height() - 96;
  };

  Board.prototype.receiveSectorData = function(sectorX, sectorY, squares) {
    this.sectorData.set(sectorX, sectorY, squares);
    this.makeSectorDomNode(sectorX, sectorY);
    return this.scrollSector(sectorX, sectorY);
  };

  Board.prototype.loadSectorsOnScreen = function() {
    var $domNode, endSectorX, endSectorY, sectorPixelSize, sectorSectorX, sectorSectorY, sectorX, sectorY, sectorsHigh, sectorsWide, startSectorX, startSectorY, x, y, _i, _j, _k, _l, _len, _ref, _results;
    sectorPixelSize = this.sectorSize * this.gridSize;
    sectorsWide = Math.ceil(this.getViewWidth() / this.sectorSize / this.gridSize);
    sectorsHigh = Math.ceil(this.getViewHeight() / this.sectorSize / this.gridSize);
    startSectorX = null;
    startSectorY = null;
    endSectorX = null;
    endSectorY = null;
    for (sectorSectorX = _i = 0; 0 <= sectorsWide ? _i <= sectorsWide : _i >= sectorsWide; sectorSectorX = 0 <= sectorsWide ? ++_i : --_i) {
      for (sectorSectorY = _j = 0; 0 <= sectorsHigh ? _j <= sectorsHigh : _j >= sectorsHigh; sectorSectorY = 0 <= sectorsHigh ? ++_j : --_j) {
        x = (Math.floor(this.scroll.x / sectorPixelSize)) + sectorSectorX;
        y = (Math.floor(this.scroll.y / sectorPixelSize)) + sectorSectorY;
        if (startSectorX === null || x < startSectorX) {
          startSectorX = x;
        }
        if (startSectorY === null || y < startSectorY) {
          startSectorY = y;
        }
        if (endSectorX === null || x > endSectorX) {
          endSectorX = x;
        }
        if (endSectorY === null || y > endSectorY) {
          endSectorY = x;
        }
      }
    }
    _ref = this.sectorDomNodes.values();
    for (_k = 0, _len = _ref.length; _k < _len; _k++) {
      $domNode = _ref[_k];
      sectorX = $domNode.data('y');
      sectorY = $domNode.data('x');
      if (!((sectorX <= endSectorX && sectorX >= startSectorX) && (sectorY <= endSectorY && sectorY >= startSectorY))) {
        this.sectorDomNodes["delete"](sectorX, sectorY).remove();
      }
    }
    _results = [];
    for (sectorX = _l = startSectorX; startSectorX <= endSectorX ? _l <= endSectorX : _l >= endSectorX; sectorX = startSectorX <= endSectorX ? ++_l : --_l) {
      _results.push((function() {
        var _m, _results1;
        _results1 = [];
        for (sectorY = _m = startSectorY; startSectorY <= endSectorY ? _m <= endSectorY : _m >= endSectorY; sectorY = startSectorY <= endSectorY ? ++_m : --_m) {
          if (this.sectorDomNodes.get(sectorX, sectorY) === null) {
            if (this.sectorData.get(sectorX, sectorY) === null) {
              this.sectorData.set(sectorX, sectorY, 'loading');
              _results1.push($(this.selector).trigger('needsector', [sectorX, sectorY]));
            } else if (this.sectorData.get(sectorX, sectorY) !== 'loading') {
              this.makeSectorDomNode(sectorX, sectorY);
              _results1.push(this.scrollSector(sectorX, sectorY));
            } else {
              _results1.push(void 0);
            }
          } else {
            if (this.sectorDomNodes.get(sectorX, sectorY) !== 'loading') {
              _results1.push(this.scrollSector(sectorX, sectorY));
            } else {
              _results1.push(void 0);
            }
          }
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  Board.prototype.makeSectorDomNode = function(sectorX, sectorY) {
    var $sectorDomNode, $squareDomNode, col, row, thisSectorData, thisSquare, _i, _ref, _results;
    $sectorDomNode = $('<div class="sector disable-select"></div>');
    $sectorDomNode.data('x', sectorX);
    $sectorDomNode.data('y', sectorY);
    $(this.selector).append($sectorDomNode);
    this.sectorDomNodes.set(sectorX, sectorY, $sectorDomNode);
    thisSectorData = this.sectorData.get(sectorX, sectorY);
    _results = [];
    for (row = _i = 0, _ref = this.sectorSize; 0 <= _ref ? _i < _ref : _i > _ref; row = 0 <= _ref ? ++_i : --_i) {
      _results.push((function() {
        var _j, _ref1, _results1;
        _results1 = [];
        for (col = _j = 0, _ref1 = this.sectorSize; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; col = 0 <= _ref1 ? ++_j : --_j) {
          thisSquare = thisSectorData[sectorX * this.sectorSize + col][sectorY * this.sectorSize + row];
          $squareDomNode = $('<div class="grid-square">\
                                        <div class="subtile north-west"></div>\
                                        <div class="subtile north-east"></div>\
                                        <div class="subtile south-west"></div>\
                                        <div class="subtile south-east"></div>\
                                    </div>');
          $squareDomNode.css('left', (col * this.gridSize) + 'px').css('top', (row * this.gridSize) + 'px');
          if (thisSquare.terrainType === 'water' || thisSquare.terrainType === 'mountains' || thisSquare.terrainType === 'forest') {
            $squareDomNode.find('.subtile').css('background-image', 'url(/static/images/' + thisSquare.terrainType + '-tiles.png)');
            $squareDomNode.find('.north-west').css('background-position', this.getTile24CSSOffset(thisSquare.northWestTile24));
            $squareDomNode.find('.north-east').css('background-position', this.getTile24CSSOffset(thisSquare.northEastTile24));
            $squareDomNode.find('.south-west').css('background-position', this.getTile24CSSOffset(thisSquare.southWestTile24));
            $squareDomNode.find('.south-east').css('background-position', this.getTile24CSSOffset(thisSquare.southEastTile24));
          }
          $squareDomNode.css({
            'background-color': '#00aa44'
          });
          $squareDomNode.data('col', this.col).data('row', this.row);
          _results1.push($sectorDomNode.append($squareDomNode));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  Board.prototype.scrollSector = function(sectorX, sectorY) {
    var $domNode;
    $domNode = this.sectorDomNodes.get(sectorX, sectorY);
    $domNode.css('left', ((sectorX * this.sectorSize * this.gridSize) - this.scroll.x) + 'px');
    return $domNode.css('top', ((sectorY * this.sectorSize * this.gridSize) - this.scroll.y) + 'px');
  };

  Board.prototype.getTile24CSSOffset = function(tile) {
    return (24 * tile % 144 * -1) + 'px ' + (parseInt(24 * tile / 144) * 24 * -1) + 'px';
  };

  return Board;

})();
