// Generated by CoffeeScript 1.10.0
angular.module('clock').service('DimmerService', function() {
  Number.prototype.mapFloat = function(in_min, in_max, out_min, out_max) {
    return parseFloat((this - in_min) * (out_max - out_min) / (in_max - in_min) + out_min);
  };
  this.range = [22, 6];
  this.norm_range = function() {
    var end, offset, start;
    offset = Math.abs(this.range[0] - 24);
    start = this.range[0] + offset - 24;
    end = this.range[this.range.length - 1] + offset;
    return {
      start: start,
      end: end,
      offset: offset
    };
  };
  this.dim = function(time) {
    var norm_range, norm_time1, norm_time2, off_time;
    norm_range = this.norm_range();
    off_time = time + norm_range.offset;
    off_time = off_time >= 24 ? off_time - 24 : off_time;
    norm_time1 = off_time.mapFloat(norm_range.start, norm_range.end, 1.0, -.5);
    norm_time2 = off_time.mapFloat(norm_range.start, norm_range.end, -.5, 1.0);
    return Math.min(1, Math.max(norm_time1, norm_time2));
  };
});
