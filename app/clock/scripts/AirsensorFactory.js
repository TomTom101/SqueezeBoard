angular.module('clock').factory('AirsensorFactory', function() {
  var qualityIndex, streamAirsensor;
  Number.prototype.map = function(in_min, in_max, out_min, out_max) {
    return parseInt((this - in_min) * (out_max - out_min) / (in_max - in_min) + out_min);
  };
  streamAirsensor = function(callback) {
    var airstream;
    if (typeof EventSource === "undefined") {
      return steroids.logger.log("EventSource not supported! Bad.");
    } else {
      airstream = new EventSource('http://192.168.0.18:8080/rest/events?topics=smarthome/items/exec_command_927931ae_output/state');
      airstream.addEventListener("message", function(message) {
        var data, event;
        event = JSON.parse(message.data);
        if (event.type === 'ItemStateChangedEvent') {
          data = JSON.parse(event.payload);
          return callback(qualityIndex(data.value));
        }
      });
      return airstream.onerror = function(error) {
        return steroids.logger.log("Error with EventSource");
      };
    }
  };
  qualityIndex = function(data) {
    var hslHue, voc;
    voc = parseInt(data);
    hslHue = voc.map(100, 0, 120, 0);
    return {
      hsl: hslHue,
      index: voc
    };
  };
  return {
    streamAirsensor: streamAirsensor
  };
});
