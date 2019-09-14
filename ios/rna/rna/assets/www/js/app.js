// Ionic Starter App
// angular.module is a global place for creating, registering and retrieving Angular modules
// 'starter' is the name of this angular module example (also set in a <body> attribute in index.html)
// the 2nd parameter is an array of 'requires'
// 'starter.controllers' is found in controllers.js
var db = null;
var ws = 'http://marcos.mineolo.com/rna/'; // Url para consumir el ws
//var ws = 'http://app.radionacional.com.ar/'; // Url para consumir el ws
angular.module('starter', ['ionic', 'starter.controllers', 'ngCordova', 'ngSanitize'])

.service('CordovaService', function() {
  document.addEventListener("deviceready", function() {
    //alert('** cordova ready **');
  }, false);
})

.run(function($ionicPlatform, $ionicPopup, $location, $ionicHistory, $cordovaSQLite, CordovaService) {

 $ionicPlatform.ready(function() {
	 
	// Crear la base de datos
	db = $cordovaSQLite.openDB("radioNacional.db");
	q = 'CREATE TABLE IF NOT EXISTS favoritos (id INTEGER PRIMARY KEY AUTOINCREMENT, emisora INTEGER)';
	$cordovaSQLite.execute(db, q);
 
	$ionicPlatform.registerBackButtonAction(function () {
	if ($location.path() == '/app/favoritos') {
		var confirmPopup = $ionicPopup.confirm({
			title: 'Desea cerrar la aplicación?',
			template: 'Seguro desea cerrar la aplicación?',
			cancelText: 'Cancelar',
			okText: 'Salir'
			});
			confirmPopup.then(function(res) {
				if(res) {
					navigator.app.exitApp();
				}
		   });
	} else {
		$ionicHistory.goBack();
	}
    }, 100);

    // Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
    // for form inputs)
    if (window.cordova && window.cordova.plugins.Keyboard) {
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
    }
    if (window.StatusBar) {
      // org.apache.cordova.statusbar required
      StatusBar.styleDefault();
    }

  });
})

.config(function($stateProvider, $urlRouterProvider, $ionicConfigProvider, $compileProvider) {
   // $compileProvider.aHrefSanitizationWhitelist(/^\s*((https?|ftp|mailto|file|tel):)|#/);
   // $compileProvider.imgSrcSanitizationWhitelist(/^\s*(https?|http?|ftp|file|blob|content):|data:image\//);
   $ionicConfigProvider.views.maxCache(0);
   $stateProvider
	  .state('app', {
		url: "/app",
		abstract: true,
		templateUrl: "templates/menu.html",
		controller: 'AppCtrl'
	  })

    .state('app.emisoras', {
      url: "/emisoras/:todas",
      views: {
        'menuContent': {
          templateUrl: "templates/emisoras.html",
          controller: 'Emisoras'
        }
      }
    })

    .state('app.noticias', {
	  url: "/noticias/:emisoraId",
      views: {
        'menuContent': {
          templateUrl: "templates/noticias.html",
          controller: 'Reproductor'
        }
      }
    })

    .state('app.programacion', {
	  url: "/programacion/:emisoraId/:banda",
      views: {
        'menuContent': {
          templateUrl: "templates/programacion.html",
          controller: 'Reproductor'
        }
      }
    })

    .state('app.contacto', {
	  url: "/contacto",
      views: {
        'menuContent': {
          templateUrl: "templates/contacto.html",
          controller: 'Contacto'
        }
      }
    })

    .state('app.error', {
	  url: "/error",
      views: {
        'menuContent': {
          templateUrl: "templates/error.html",
          controller: 'Errores'
        }
      }
    })

    .state('app.favoritos', {
      url: "/favoritos",
      views: {
        'menuContent': {
          templateUrl: "templates/favoritos.html",
          controller: 'Favoritos'
        }
      }
    })
    // .state('app.prueba', {
      // url: "/prueba",
      // views: {
        // 'menuContent': {
          // templateUrl: "templates/prueba.html",
          // controller: 'Prueba'
        // }
      // }
    // })
	.state('app.single', {
    url: "/emisoras/:emisoraId/:frecuencia",
    views: {
      'menuContent': {
        templateUrl: "templates/reproducir.html",
        controller: 'Reproductor'
      }
    }
  });

  //if none of the above states are matched, use this as the fallback
  $urlRouterProvider.otherwise('/app/emisoras/si');
});
