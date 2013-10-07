// Generated by CoffeeScript 1.6.3
var Camera;

Camera = (function() {
  function Camera() {
    this.x = 0;
    this.y = 0;
    this.lastX = 0;
    this.lastY = 0;
    this.width = 800;
    this.height = 600;
    this.zoomFactor = 1;
    this.zoomLevel = 1;
    this.maxZoomLevel = 3;
    this.zoomedGridSize = TB.gridSize;
    this.subGridSize = TB.gridSize / 2;
  }

  Camera.prototype.move = function(x, y) {
    this.x = x;
    this.y = y;
  };

  Camera.prototype.worldToScreenPosX = function(worldX) {
    return worldX - this.x;
  };

  Camera.prototype.worldToScreenPosY = function(worldY) {
    return worldY - this.y;
  };

  Camera.prototype.screenToWorldPosX = function(screenX) {
    return screenX + this.x;
  };

  Camera.prototype.screenToWorldPosY = function(screenY) {
    return screenY + this.y;
  };

  Camera.prototype.pixelToSectorCoord = function(coord) {
    return Math.floor(coord / (TB.gridSize * this.zoomFactor));
  };

  Camera.prototype.mouseXToCol = function(mouseX) {
    return TB.pixelToSectorCoord(mouseX + this.x);
  };

  Camera.prototype.mouseYToRow = function(mouseY) {
    return TB.pixelToSectorCoord(mouseY + this.y);
  };

  Camera.prototype.resize = function() {
    this.width = $(window).width() - (48 + 20) - 220;
    return this.height = $(window).height() - 96;
  };

  Camera.prototype.zoom = function(x, y, delta) {
    this.zoomLevel -= delta;
    if (this.zoomLevel < 1) {
      this.zoomLevel = 1;
    }
    if (this.zoomLevel > this.maxZoomLevel) {
      this.zoomLevel = this.maxZoomLevel;
    }
    if (this.zoomLevel === 1) {
      this.zoomFactor = 1;
    }
    if (this.zoomLevel === 2) {
      this.zoomFactor = 36 / 48;
    }
    if (this.zoomLevel === 3) {
      this.zoomFactor = 24 / 48;
    }
    this.zoomedGridSize = TB.gridSize * this.zoomFactor;
    return this.subGridSize = this.zoomedGridSize / 2;
  };

  return Camera;

})();