// Generated by CoffeeScript 1.10.0
angular.module('clock', ['common', 'ngAnimate']).controller('ClockController', [
  '$scope', '$interval', '$http', 'ClockService', 'ForecastFactory', 'AirsensorFactory', function($scope, $interval, $http, ClockService, ForecastFactory, AirsensorFactory) {
    var getForecast, getTomorrowData, init, initAirvalueStream, setAirColor, tick;
    document.addEventListener('deviceready', function() {
      window.brightness = cordova.require("cordova.plugin.Brightness.Brightness");
      return brightness.setKeepScreenOn(true);
    });
    window.addEventListener("batterystatus", function(status) {
      return $scope.message = status.level;
    }, false);
    init = function() {
      steroids.statusBar.hide();
      $interval(tick, 1000);
      $interval(getForecast, 1000 * 60 * 10);
      $scope.airquality = {
        index: "?"
      };
      setAirColor(0);
      getForecast();
      return initAirvalueStream();
    };
    tick = function() {
      $scope.time = ClockService.getTime();
      return $scope.date = ClockService.getDate();
    };
    setAirColor = function(hsl) {
      var color;
      color = one.color("hsl(" + hsl + ", 100%, 50%)");
      return $scope.airColor = {
        color: color.hex()
      };
    };
    getTomorrowData = function(response) {
      var find, tomorrow, tomorrow_data;
      tomorrow = moment().add(1, 'd').startOf('day').utc();
      find = find || {};
      steroids.logger.log("Tommorrow is " + (tomorrow.format()));
      find.time = parseInt(tomorrow.format('X'));
      tomorrow_data = _.where(response.daily.data, find);
      return tomorrow_data[0];
    };
    getForecast = function() {
      return ForecastFactory.currentForecast(function(error, response) {
        if (error) {
          return steroids.logger.error("Error occured: " + error);
        } else {
          $scope.weather_current = response.currently;
          return $scope.weather_tomorrow = getTomorrowData(response);
        }
      });
    };
    initAirvalueStream = function() {
      steroids.logger.log("initAirvalueStream");
      return AirsensorFactory.streamAirsensor(function(data) {
        steroids.logger.log("initAirvalueStream");
        return $scope.$apply(function() {
          $scope.airquality = data;
          return setAirColor($scope.airquality.hsl);
        });
      });
    };
    return init();
  }
]).directive('animateOnChange', function($animate, $timeout) {
  return function(scope, elem, attr) {
    return scope.$watch(attr.animateOnChange, function(nv, ov) {
      if (nv !== ov) {
        return $animate.addClass(elem, 'change').then(function() {
          return $timeout(function() {
            return $animate.removeClass(elem, 'change');
          }, 2000);
        });
      }
    });
  };
});
