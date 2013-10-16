// Generated by CoffeeScript 1.6.3
var Account, requestAnimationFrame;

requestAnimationFrame = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame || window.msRequestAnimationFrame;

window.requestAnimationFrame = requestAnimationFrame;

Account = (function() {
  function Account(id, username, color) {
    this.id = id;
    this.username = username;
    this.color = color;
  }

  return Account;

})();

window.TB = {
  players: {},
  currentAction: 'move',
  dragging: false,
  lastMouse: {
    x: 0,
    y: 0
  },
  lastScroll: {
    x: 0,
    y: 0
  },
  activeSquare: {
    col: 0,
    row: 0
  },
  unitSize: 32,
  gridSize: 48,
  sectorSize: 50,
  myAccount: null,
  accounts: {},
  isInitialPlacement: false,
  images: {
    othertilesImage: $('#othertiles-image').get(0),
    gridImage: $('#grid-image').get(0),
    forestTiles: $('#forest-tiles').get(0),
    mountainsTiles: $('#mountains-tiles').get(0),
    waterTiles: $('#water-tiles').get(0),
    roadTiles: $('#road-tiles').get(0),
    cityTiles: $('#city-tiles').get(0)
  },
  init: function() {
    TB.ctx = $('.board').get(0).getContext('2d');
    TB.camera = new Camera();
    TB.board = new Board();
    TB.actions = new ActionManager();
    TB.fetcher = new DataFetcher();
    return TB.fetcher.loadInitialData(function(data) {
      TB.registerEventHandlers();
      TB.isInitialPlacement = data.isInitialPlacement;
      if (TB.isInitialPlacement) {
        $('.game-toolbar').find('.btn-action').not('.btn-initial').not('.btn-undo').hide();
        $('.btn-initial').trigger('click');
      } else {
        $('.game-toolbar').find('.btn-initial').hide();
        $('.btn-move').trigger('click');
      }
      TB.fpsCounter = util.makeFPSCounter(20);
      TB.myAccount = data.account;
      TB.myAccount.wood = 100;
      $('#total-unit-display').text(data.totalUnits);
      $('#wood-display').text(data.account.wood);
      $('#food-display').text(data.account.food);
      $('#ore-display').text(data.account.ore);
      $('#money-display').text(data.account.money);
      TB.actions.loadFromJSON(data.actions);
      requestAnimationFrame(TB.mainLoop);
      TB.camera.moveTo(data.centerCol * TB.camera.zoomedGridSize, data.centerRow * TB.camera.zoomedGridSize);
      TB.camera.moveBy(-TB.camera.width / 2, -TB.camera.height / 2);
      return TB.fetcher.loadSectorsOnScreen();
    });
  },
  registerEventHandlers: function() {
    var _this = this;
    $('.btn-action').click(function(event) {
      var kind;
      kind = $(this).data('action');
      if (kind === 'undo') {
        TB.actions.undo();
        requestAnimationFrame(TB.mainLoop);
      } else if (kind === 'move' && $(this).hasClass('yellow')) {
        TB.actions.cancelMove();
      } else {
        TB.currentAction = kind;
        $('.btn-action').removeClass('active');
        $(this).addClass('active');
        TB.board.showRoadOverlay = kind === 'road';
      }
      return requestAnimationFrame(TB.mainLoop);
    });
    $('.board').mousedown(function(event) {
      event.preventDefault();
      TB.lastMouse = {
        x: event.offsetX,
        y: event.offsetY
      };
      TB.lastScroll.x = TB.camera.x;
      TB.lastScroll.y = TB.camera.y;
      TB.dragging = true;
      return requestAnimationFrame(TB.mainLoop);
    });
    $('.board').mousemove((function() {
      var lastX, lastY,
        _this = this;
      lastX = null;
      lastY = null;
      return function(event) {
        if (event.clientX === lastX && event.clientY === lastY) {
          return;
        }
        lastX = event.clientX;
        lastY = event.clientY;
        TB.activeSquare.col = TB.camera.mouseXToCol(event.offsetX);
        TB.activeSquare.row = TB.camera.mouseYToRow(event.offsetY);
        if (TB.dragging) {
          event.preventDefault();
          TB.camera.moveTo(TB.lastScroll.x - (event.offsetX - TB.lastMouse.x), TB.lastScroll.y - (event.offsetY - TB.lastMouse.y));
          TB.fetcher.loadSectorsOnScreen();
        }
        return requestAnimationFrame(TB.mainLoop);
      };
    })());
    $('.board').mouseup(function(event) {
      TB.dragging = false;
      if (Math.abs(TB.camera.x - TB.lastScroll.x) < 5 && Math.abs(TB.camera.y - TB.lastScroll.y) < 5) {
        TB.actions.handleAction(TB.currentAction, TB.camera.mouseXToCol(event.offsetX), TB.camera.mouseYToRow(event.offsetY));
      }
      return requestAnimationFrame(TB.mainLoop);
    });
    $('.board').mouseleave(function(event) {
      TB.dragging = false;
      return requestAnimationFrame(TB.mainLoop);
    });
    $('.board').mousewheel(function(event, delta, deltaX, deltaY) {
      TB.camera.zoom(event.offsetX, event.offsetY, delta);
      return requestAnimationFrame(TB.mainLoop);
    });
    $(window).resize(function() {
      TB.camera.resize();
      $('.board').attr('width', TB.camera.width).attr('height', TB.camera.height);
      $('.stats-bar').css('width', TB.camera.width);
      TB.ctx = $('.board').get(0).getContext('2d');
      return requestAnimationFrame(TB.mainLoop);
    });
    $(window).trigger('resize');
    return $(window).on('sectorLoaded', function(event) {
      var accountData, accountID, amount, col, color, ownerID, row, rowData, squareData, startCol, startRow, terrainType, thisAccountData, thisUnitData, unitData, username, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
      if (event.sectorData) {
        _ref = event.sectorData.split('|'), squareData = _ref[0], unitData = _ref[1], accountData = _ref[2];
        if (squareData) {
          startCol = event.sectorX * TB.sectorSize;
          startRow = event.sectorY * TB.sectorSize;
          console.log(startCol + ' ' + startRow);
          _ref1 = squareData.split('\n');
          for (row = _i = 0, _len = _ref1.length; _i < _len; row = ++_i) {
            rowData = _ref1[row];
            _ref2 = rowData.split(',');
            for (col = _j = 0, _len1 = _ref2.length; _j < _len1; col = ++_j) {
              terrainType = _ref2[col];
              TB.board.addSquare(startCol + col, startRow + row, parseInt(terrainType));
            }
          }
        }
        if (accountData) {
          _ref3 = accountData.split('\n');
          for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
            thisAccountData = _ref3[_k];
            _ref4 = thisAccountData.split(','), accountID = _ref4[0], username = _ref4[1], color = _ref4[2];
            TB.accounts[accountID] = new Account(parseInt(accountID), username, color);
          }
        }
        if (unitData) {
          _ref5 = unitData.split('\n');
          for (_l = 0, _len3 = _ref5.length; _l < _len3; _l++) {
            thisUnitData = _ref5[_l];
            _ref6 = thisUnitData.split(','), col = _ref6[0], row = _ref6[1], ownerID = _ref6[2], amount = _ref6[3];
            TB.board.addUnit(parseInt(col), parseInt(row), parseInt(ownerID), parseInt(amount));
          }
        }
        return requestAnimationFrame(TB.mainLoop);
      }
    });
  },
  mainLoop: function(timestamp) {
    TB.board.draw();
    TB.actions.draw();
    return TB.drawCursor();
  },
  drawCursor: function() {
    var cursorSize, screenX, screenY, textX, textY;
    cursorSize = TB.camera.zoomedGridSize;
    screenX = TB.camera.worldColToScreenPosX(TB.activeSquare.col);
    screenY = TB.camera.worldRowToScreenPosY(TB.activeSquare.row);
    TB.ctx.save();
    TB.ctx.strokeStyle = 'black';
    TB.ctx.fillStyle = 'black';
    TB.ctx.strokeRect(screenX, screenY, cursorSize, cursorSize);
    TB.ctx.restore();
    textX = screenX - 8;
    textY = screenY - 4;
    return TB.fillOutlinedText(TB.activeSquare.col + ',' + TB.activeSquare.row, textX, textY);
  },
  fillOutlinedText: function(text, screenX, screenY) {
    TB.ctx.save();
    TB.ctx.font = 'bold 16px Arial';
    TB.ctx.fillStyle = 'black';
    TB.ctx.fillText(text, screenX + 1, screenY + 1);
    TB.ctx.fillText(text, screenX + 1, screenY - 1);
    TB.ctx.fillText(text, screenX - 1, screenY + 1);
    TB.ctx.fillText(text, screenX - 1, screenY - 1);
    TB.ctx.fillStyle = 'white';
    TB.ctx.fillText(text, screenX, screenY);
    return TB.ctx.restore();
  }
};
