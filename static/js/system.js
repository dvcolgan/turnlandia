// Generated by CoffeeScript 1.6.3
var requestAnimationFrame;

requestAnimationFrame = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame || window.msRequestAnimationFrame;

window.requestAnimationFrame = requestAnimationFrame;

window.TB = {
  players: {},
  currentAction: 'initial',
  dragging: false,
  lastMouse: {
    x: 0,
    y: 0
  },
  lastScroll: {
    x: 0,
    y: 0
  },
  unitSize: 32,
  gridSize: 48,
  sectorSize: 10,
  images: {
    gridImage: $('#grid-image').get(0),
    forestTiles: $('#forest-tiles').get(0),
    mountainsTiles: $('#mountains-tiles').get(0),
    waterTiles: $('#water-tiles').get(0)
  },
  init: function(selector) {
    TB.selector = selector;
    TB.ctx = $(TB.selector).get(0).getContext('2d');
    TB.camera = new Camera();
    TB.board = new Board();
    TB.cursor = new Cursor();
    TB.actions = new ActionManager();
    TB.fetcher = new DataFetcher();
    return TB.fetcher.loadInitialData(function(data) {
      var action, _i, _len, _ref;
      _ref = data.actions;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        action = _ref[_i];
        TB.actions.add(action);
      }
      TB.registerEventHandlers();
      TB.startMainLoop();
      return TB.fetcher.loadSectorsOnScreen();
    });
  },
  registerEventHandlers: function() {
    var _this = this;
    $(TB.selector).mousedown(function(event) {
      event.preventDefault();
      TB.lastMouse = {
        x: event.offsetX,
        y: event.offsetY
      };
      TB.lastScroll.x = TB.camera.x;
      TB.lastScroll.y = TB.camera.y;
      return TB.dragging = true;
    });
    $(TB.selector).mousemove(function(event) {
      TB.cursor.move(event.offsetX + TB.camera.x, event.offsetY + TB.camera.y);
      if (TB.dragging) {
        event.preventDefault();
        TB.camera.move(TB.lastScroll.x - (event.offsetX - TB.lastMouse.x), TB.lastScroll.y - (event.offsetY - TB.lastMouse.y));
        return TB.fetcher.loadSectorsOnScreen();
      }
    });
    $(document).mouseup(function(event) {
      return TB.dragging = false;
    });
    $(TB.selector).mousewheel(function(event, delta, deltaX, deltaY) {
      return TB.camera.zoom(event.offsetX, event.offsetY, delta);
    });
    $(window).resize(function() {
      TB.camera.resize();
      $(TB.selector).attr('width', TB.camera.width).attr('height', TB.camera.height);
      return TB.ctx = $(TB.selector).get(0).getContext('2d');
    });
    $(window).trigger('resize');
    return $(window).on('sectorLoaded', function(event) {
      var square, _i, _len, _ref, _results;
      _ref = event.squareData;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        square = _ref[_i];
        _results.push(TB.board.addSquare(square));
      }
      return _results;
    });
  },
  startMainLoop: function() {
    var mainLoop, start;
    start = null;
    mainLoop = function(timestamp) {
      TB.board.draw();
      TB.actions.draw();
      TB.cursor.draw();
      return requestAnimationFrame(mainLoop);
    };
    return requestAnimationFrame(mainLoop);
  },
  fillOutlinedText: function(text, screenX, screenY) {
    TB.ctx.fillStyle = 'black';
    TB.ctx.fillText(text, screenX + 1, screenY + 1);
    TB.ctx.fillText(text, screenX + 1, screenY - 1);
    TB.ctx.fillText(text, screenX - 1, screenY + 1);
    TB.ctx.fillText(text, screenX - 1, screenY - 1);
    TB.ctx.fillStyle = 'white';
    return TB.ctx.fillText(text, screenX, screenY);
  }
};
