(function() {
  'use strict';
  angular.module('underscore', []).factory('_', function() {
    var underscore;
    underscore = window._;
    underscore.mixin(underscore.str.exports());
    return underscore;
  });

  angular.module('547ProjectApp', ['ngAnimate', 'ngCookies', 'ngResource', 'ngRoute', 'ngSanitize', 'ngTouch', 'underscore', 'ui.select']).config(function($routeProvider) {
    return $routeProvider.when('/', {
      templateUrl: 'views/main.html',
      controller: 'MainCtrl',
      controllerAs: 'main'
    }).when('/about', {
      templateUrl: 'views/about.html',
      controller: 'AboutCtrl',
      controllerAs: 'about'
    }).otherwise({
      redirectTo: '/'
    });
  });

}).call(this);

//# sourceMappingURL=app.js.map
