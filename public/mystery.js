app = angular.module("mys", ["ngRoute"]).config(['$routeProvider', '$locationProvider', function($routeProvider, $locationProvider){
  $routeProvider.when('/', {
    templateUrl: 'blog.html',
    controller: 'BlogCtrl'
  }).when('/blog/:blogName', {
    templateUrl: 'blog.html',
    controller: 'BlogCtrl'
  });
}]);

app.factory('BlogPagesService', function(){
  // In the future, consider replacing with a rails API that uses S3
  // This service is basically stubbing a proper backend
  var posts = [
    { date: new Date(2014, 4, 26, 19, 30), title: "First Post", url: "posts/development/first_post.html", blog: "development" }
  ];
  
  var request = function(blogName){
    return function(pgNum, pgSize){
      var start = (pgNum - 1) * pgSize;
      return filter(blogName).slice(start, start + pgSize);
    };
  };
  
  var filter = function(blogName){
    if(!blogName){
      return posts;
    }
    var retval = [];
    angular.forEach(posts, function(item, _){
      if(item.blog === blogName){
        retval.push(item);
      }
    });
    return retval;
  };
  
  return {
    request: request
  };
});

app.controller('BlogCtrl', function(BlogPagesService, $scope, $rootScope, $location, $route){
  var search = $location.search();
  var routeParams = $route.current.params;
  $scope.blogName = routeParams.blogName ? routeParams.blogName : false;
  $scope.pgNum = search.pgNum ? search.pgNum : 1;
  $scope.pgSize = search.pgSize ? search.pgSize : 5;
  $scope.request = BlogPagesService.request($scope.blogName);
  $scope.posts = $scope.request($scope.pgNum, $scope.pgSize);
});