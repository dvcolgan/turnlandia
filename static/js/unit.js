// Generated by CoffeeScript 1.6.3
var Unit;

Unit = (function() {
  function Unit(col, row, ownerID, amount) {
    this.col = col;
    this.row = row;
    this.ownerID = ownerID;
    this.amount = amount;
    this.ownerColor = TB.accounts[this.ownerID].color;
  }

  Unit.prototype.draw = function() {
    var rgb, screenX, screenY, textX, textY, unitRadius, unitX, unitY;
    screenX = TB.camera.worldToScreenPosX(this.col * TB.gridSize);
    screenY = TB.camera.worldToScreenPosY(this.row * TB.gridSize);
    unitX = screenX + TB.camera.zoomedGridSize / 2;
    unitY = screenY + TB.camera.zoomedGridSize / 2;
    unitRadius = TB.camera.zoomedUnitSize / 2;
    textX = unitX;
    textY = unitY + 5;
    TB.ctx.save();
    TB.ctx.fillStyle = this.ownerColor;
    rgb = util.hexToRGB(this.ownerColor);
    rgb.r = parseInt(rgb.r * 0.4);
    rgb.g = parseInt(rgb.g * 0.4);
    rgb.b = parseInt(rgb.b * 0.4);
    TB.ctx.strokeStyle = "rgba(" + rgb.r + "," + rgb.g + "," + rgb.b + ",1)";
    TB.ctx.lineWidth = 2;
    TB.ctx.beginPath();
    TB.ctx.arc(unitX, unitY, TB.camera.zoomedUnitSize / 2, 0, 2 * Math.PI);
    TB.ctx.fill();
    TB.ctx.stroke();
    TB.ctx.textAlign = 'center';
    TB.fillOutlinedText(this.amount, textX, textY);
    return TB.ctx.restore();
  };

  return Unit;

})();
