// Generated by CoffeeScript 1.6.3
var Cursor;

Cursor = (function() {
  function Cursor() {
    this.pos = {
      x: 0,
      y: 0
    };
  }

  Cursor.prototype.move = function(x, y) {
    this.pos.x = x;
    return this.pos.y = y;
  };

  Cursor.prototype.draw = function() {
    var col, cursorSize, offset, row, screenX, screenY, snappedX, snappedY, textX, textY;
    cursorSize = TB.gridSize * TB.camera.zoomFactor;
    offset = cursorSize / 2;
    TB.ctx.strokeStyle = 'black';
    TB.ctx.fillStyle = 'black';
    col = Math.floor(this.pos.x / cursorSize);
    row = Math.floor(this.pos.y / cursorSize);
    snappedX = col * cursorSize;
    snappedY = row * cursorSize;
    screenX = TB.camera.worldToScreenPosX(snappedX);
    screenY = TB.camera.worldToScreenPosY(snappedY);
    TB.ctx.strokeRect(screenX, screenY, cursorSize, cursorSize);
    TB.ctx.font = 'bold 16px Arial';
    TB.ctx.fillStyle = 'black';
    textX = screenX - 8;
    textY = screenY - 4;
    TB.ctx.fillText(col + ',' + row, textX + 1, textY + 1);
    TB.ctx.fillText(col + ',' + row, textX - 1, textY + 1);
    TB.ctx.fillText(col + ',' + row, textX + 1, textY - 1);
    TB.ctx.fillText(col + ',' + row, textX - 1, textY - 1);
    TB.ctx.fillStyle = 'white';
    return TB.ctx.fillText(col + ',' + row, textX, textY);
  };

  return Cursor;

})();