angular.module('clock').factory('AirsensorFactory', function() {
  var airstream, connectSSE, doEvery, doIn, qualityIndex, reconnecting, streamAirsensor;
  airstream = null;
  reconnecting = false;
  Number.prototype.map = function(in_min, in_max, out_min, out_max) {
    return parseInt((this - in_min) * (out_max - out_min) / (in_max - in_min) + out_min);
  };
  doEvery = function(sec, func) {
    return setInterval(func, sec * 1000);
  };
  doIn = function(sec, func) {
    return setTimeout(func, sec * 1000);
  };
  connectSSE = function(callback) {
    airstream = new EventSource('http://192.168.0.18:8080/rest/events?topics=smarthome/items/exec_command_927931ae_output/state');
    airstream.addEventListener("message", function(message) {
      var data, event;
      event = JSON.parse(message.data);
      if (event.type === 'ItemStateEvent') {
        data = JSON.parse(event.payload);
        return callback(qualityIndex(data.value));
      }
    });
    return airstream.onerror = function() {
      steroids.logger.log("EventSource error");
      return callback(qualityIndex('error'));
    };
  };
  streamAirsensor = function(callback) {
    doEvery(10, function() {
      if (airstream.readyState === 2) {
        steroids.logger.log("Reconnect now");
        return connectSSE(callback);
      }
    });
    if (typeof EventSource === "undefined") {
      return steroids.logger.log("EventSource not supported! Bad.");
    } else {
      return connectSSE(callback);
    }
  };
  qualityIndex = function(data) {
    var hslHue, voc;
    voc = parseInt(data);
    if (isNaN(voc)) {
      hslHue = 0;
      voc = '-';
    } else {
      hslHue = voc.map(100, 0, 120, 0);
    }
    return {
      hsl: hslHue,
      index: voc
    };
  };
  return {
    streamAirsensor: streamAirsensor
  };
});
