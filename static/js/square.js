// Generated by CoffeeScript 1.6.3
var Square;

Square = (function() {
  function Square(json) {
    _.extend(this, json);
  }

  Square.prototype.draw = function() {
    var screenX, screenY, textX, textY, unitRadius, unitX, unitY;
    screenX = (this.col * TB.camera.zoomedGridSize) - TB.camera.x;
    screenY = (this.row * TB.camera.zoomedGridSize) - TB.camera.y;
    if (this.terrainType === 'water' || this.terrainType === 'mountains' || this.terrainType === 'forest') {
      this.drawSubTile(TB.images[this.terrainType + 'Tiles'], this.northWestTile24, screenX, screenY, TB.camera.subGridSize, 0, 0);
      this.drawSubTile(TB.images[this.terrainType + 'Tiles'], this.northEastTile24, screenX, screenY, TB.camera.subGridSize, TB.camera.subGridSize, 0);
      this.drawSubTile(TB.images[this.terrainType + 'Tiles'], this.southWestTile24, screenX, screenY, TB.camera.subGridSize, 0, TB.camera.subGridSize);
      this.drawSubTile(TB.images[this.terrainType + 'Tiles'], this.southEastTile24, screenX, screenY, TB.camera.subGridSize, TB.camera.subGridSize, TB.camera.subGridSize);
      unitX = screenX + TB.camera.zoomedGridSize / 2;
      unitY = screenY + TB.camera.zoomedGridSize / 2;
      unitRadius = TB.camera.zoomedUnitSize / 2;
      textX = unitX;
      textY = unitY + (6 * TB.zoomFactor);
      if (this.unitAmount > 0) {
        TB.ctx.fillStyle = 'blue';
        TB.ctx.beginPath();
        TB.ctx.arc(unitX, unitY, unitRadius, 0, 2 * Math.PI);
        TB.ctx.fill();
        TB.ctx.stroke();
        TB.ctx.fillStyle = 'black';
        TB.ctx.fillText(this.unitAmount, textX + 1, textY + 1);
        TB.ctx.fillText(this.unitAmount, textX + 1, textY - 1);
        TB.ctx.fillText(this.unitAmount, textX - 1, textY + 1);
        TB.ctx.fillText(this.unitAmount, textX - 1, textY - 1);
        TB.ctx.fillStyle = 'white';
        return TB.ctx.fillText(this.unitAmount, textX, textY);
      }
    }
  };

  Square.prototype.drawSubTile = function(image, subTile, screenX, screenY, subGridSize, subTileOffsetX, subTileOffsetY) {
    return TB.ctx.drawImage(image, this.getTile24XOffset(subTile), this.getTile24YOffset(subTile), TB.gridSize / 2, TB.gridSize / 2, screenX + subTileOffsetX, screenY + subTileOffsetY, subGridSize, subGridSize);
  };

  Square.prototype.getTile24XOffset = function(tile) {
    return 24 * tile % 144;
  };

  Square.prototype.getTile24YOffset = function(tile) {
    return parseInt(24 * tile / 144) * 24;
  };

  return Square;

})();
