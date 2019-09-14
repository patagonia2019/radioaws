angular.module('starter.controllers', ['ngCordova'])

.controller('AppCtrl', function($scope, $rootScope, $ionicPlatform, $cordovaSQLite) {
	// Controller para el menú lo dejo por si en futuro se quiere hacer algo
})

.controller('Contacto', function($scope, $rootScope, $http) {

    $scope.submit = function(){
		var link = ws + 'api.php';
        $http.post(link, {username : $scope.data.username, mail : $scope.data.mail, comentarios : $scope.data.comentarios}).then(function (res){
			var ele_nombre = document.getElementById("nombre");
			var ele_mail = document.getElementById("mail");
			var ele_comentarios = document.getElementById("comentarios");
			var ele_respuesta = document.getElementById("respuesta");
			ele_nombre.value = '';
			ele_mail.value = '';
			ele_comentarios.value = '';
			ele_respuesta.style.display = 'inline';
            $scope.response = res.data;
        });
    }


  // Controller para envío de mail y demás
  $scope.stop = function() {
	$rootScope.audio.pause();
	$rootScope.audio = null;
	$scope.footer_display_text = 'block';
	$scope.footer_display_button = 'none';
	document.getElementById('texto').style.display = 'block';
	document.getElementById('botonParar').style.display = 'none';
	$rootScope.nombre = '';
  }

  if ($rootScope.audio && $rootScope.nombre){
	 $scope.footer_display_text = 'none';
	 $scope.footer_display_button = 'block';
	 $scope.nombre = $rootScope.nombre;
  } else {
	 $scope.footer_display_text = 'block';
	 $scope.footer_display_button = 'none';
  }

})

.controller('Errores', function($scope, $rootScope) {
	// Controller para el manejo de los errores.
})

.controller('Favoritos', function($scope, $rootScope, $stateParams, $ionicScrollDelegate, $http, $cordovaSQLite, $location) {
	  /* Función para eliminar favoritos*/
	  $scope.del = function(emi) {
			// ocultar listado
			//document.getElementById('listado').style.display = 'none';
			//document.getElementById('cargando_listado').style.display = 'block';
            var arr = [];
            // Execute SELECT statement to load message from database.
            $cordovaSQLite.execute(db, 'DELETE FROM favoritos WHERE emisora = "' + emi + '"')
                .then(
                    function(result) {
						//document.getElementById('cargando_listado').style.display = 'none';
						$location.url("/app/emisoras/no");
                    },
                    function(error) {
                        //$scope.statusMessage = "Error on loading: " + error.emisora;
						alert("Error general");
                    }
                );
	  }
	  
	  /* Función para realizar la carga de los favoritos*/
      $scope.load = function() {
            var arr = [];
			document.getElementById('cargando_listado').style.display = 'block';
			
            // Execute SELECT statement to load message from database.
            $cordovaSQLite.execute(db, 'SELECT * FROM favoritos ORDER BY id DESC')
                .then(
                    function(result) {
						if (result.rows.length <= 0) {
							$location.url("/app/emisoras/si");
						} else {
							// $rootScope.emisoras = '';
							for(var i = 0; i < result.rows.length; i++) {
								//arr.push(i.toString());
								arr.push(result.rows.item(i).emisora.toString());
							}
							$scope.messages = arr;
							//alert(arr);
							var url = ws + 'api/listar_emisoras/' + arr + '/.json?callback=JSON_CALLBACK';
							$http.jsonp(url)
								.success(function(data){
								  document.getElementById('cargando_listado').style.display = 'none';
   					  			  document.getElementById('listado').style.display = 'block';
								  $scope.messages = data.data;
								}).error(function(error) {
									// Ir a pantalla de error de conexion.
									$location.url("/app/error");
								});
						}
                    },
                    function(error) {
                        $scope.statusMessage = "Error on loading: " + error.emisora;
						alert("Error general");
                    }
                );
        }
		
  $scope.stop = function() {
	$rootScope.audio.pause();
	$rootScope.audio = null;
	$scope.footer_display_text = 'block';
	$scope.footer_display_button = 'none';
	document.getElementById('texto').style.display = 'block';
	document.getElementById('botonParar').style.display = 'none';
	$rootScope.nombre = '';
  }

  if ($rootScope.audio && $rootScope.nombre){
	 $scope.footer_display_text = 'none';
	 $scope.footer_display_button = 'block';
	 $scope.nombre = $rootScope.nombre;
  } else {
	 $scope.footer_display_text = 'block';
	 $scope.footer_display_button = 'none';
  }
		
	
})

.controller('Emisoras', function($scope, $rootScope, $stateParams, $cordovaMedia, $ionicScrollDelegate, filterFilter, $http, $cordovaSQLite, $ionicPlatform, $location) {

  // Muestro el ícono de cargando.
  document.getElementById('cargando_listado').style.display = 'block';

  // Tomar todas las emisoras
  var url = ws + 'api/listar_emisoras.json?callback=JSON_CALLBACK';
  var letters = $scope.letters = [];
  var contacts = $scope.contacts = [];
  var currentCharCode = 'A'.charCodeAt(0) - 1;

  $http.jsonp(url)
		.success(function(data){
		  $rootScope.emisoras = data.data;
          $rootScope.emisoras.forEach(function(person) {
              var personCharCode = person.last_name.toUpperCase().charCodeAt(0);
              var difference = personCharCode - currentCharCode;
              for (var i = 1; i <= difference; i++) {
                addLetter(currentCharCode + i);
              }
              currentCharCode = personCharCode;
              contacts.push(person);
            });
            document.getElementById('cargando_listado').style.display = 'none';

        }).error(function(error) {
			//console.log(error);
			//alert(error);
            // Ir a pantalla de error de conexion.
            $location.url("/app/error");
        });


  // if (!$rootScope.emisoras) { alert("error no se puede continuar."); }
  // for (var i = currentCharCode + 1; i <= 'Z'.charCodeAt(0); i++) {
   // addLetter(i);
  // }

  function addLetter(code) {
    var letter = String.fromCharCode(code);
    contacts.push({
      isLetter: true,
      letter: letter
    });
    letters.push(letter);
	return false;
  }

  $scope.getItemHeight = function(item) {
	return 0;
  };

  $scope.getItemWidth = function(item) {
    return '100%';
  };

  // $scope.scrollBottom = function() {
    // $ionicScrollDelegate.scrollBottom(true);
  // };
  
	  if ($stateParams.todas != 'si') {
		$ionicPlatform.ready(function() {
            var arr = [];
            // Execute SELECT statement to load message from database.
            $cordovaSQLite.execute(db, 'SELECT * FROM favoritos ORDER BY id DESC')
                .then(
                    function(result) {
						if (result.rows.length > 0) {
							// Ir a pantalla de Favoritos
							$location.url("/app/favoritos");
						}
                    },
                    function(error) {
                        // $scope.statusMessage = "Error on loading: " + error.emisora;
                        $scope.statusMessage = "Error on loading obteniendo emisoras.";
						//alert("Error al obtener lista de favoritos.");
                    }
                );
		});
      }

  
  var letterHasMatch = {};
  $scope.getContacts = function() {
    letterHasMatch = {};
    return contacts.filter(function(item) {
      var itemDoesMatch = !$scope.search || item.isLetter ||
	    item.first_name.toLowerCase().indexOf($scope.search.toLowerCase()) > -1 ||
        item.last_name.replace('á', 'a').toLowerCase().indexOf($scope.search.toLowerCase()) > -1 ||
        item.last_name.replace('é', 'e').toLowerCase().indexOf($scope.search.toLowerCase()) > -1 ||
        item.last_name.replace('í', 'i').toLowerCase().indexOf($scope.search.toLowerCase()) > -1 ||
        item.last_name.replace('ó', 'o').toLowerCase().indexOf($scope.search.toLowerCase()) > -1 ||
        item.last_name.replace('ú', 'u').toLowerCase().indexOf($scope.search.toLowerCase()) > -1 ;
		;

      if (!item.isLetter && itemDoesMatch) {
        var letter = item.last_name.charAt(0).toUpperCase();
      }

      return itemDoesMatch;
    }).filter(function(item) {
      if (item.isLetter && !letterHasMatch[item.letter]) {
        return false;
      }
      return true;
    });
  };

  $scope.clearSearch = function() {
    $scope.search = '';
  };

  $scope.stop = function() {
    $rootScope.audio.pause();
	$rootScope.audio = null;
	$scope.footer_display_text = 'block';
	$scope.footer_display_button = 'none';
	document.getElementById('texto').style.display = 'block';
	document.getElementById('botonParar').style.display = 'none';
	$rootScope.nombre = '';
  }

  if ($rootScope.audio && $rootScope.nombre){
	 $scope.footer_display_text = 'none';
	 $scope.footer_display_button = 'block';
	 $scope.nombre = $rootScope.nombre;
  } else {
	 $scope.footer_display_text = 'block';
	 $scope.footer_display_button = 'none';
  }

})

.controller('Reproductor', function($scope, $rootScope, $ionicPopup, $stateParams, $cordovaMedia, $cordovaLocalNotification, $http, $location, $cordovaSQLite) {

	if ($stateParams.emisoraId <= 0) {
		$location.url("/app/error");
	}

    if ($rootScope.emisoras && $rootScope.emisoras.length > 0) {
	    emisora_seleccionada = $rootScope.emisoras[$stateParams.emisoraId-1];
    } else {
	    //document.getElementById('cargando_listado').style.display = 'none';

		// Intento obtener el listado sino vuelvo a emisoras, 
		//si obtengo todas las emisoras selecciono la que necesito
		var url = ws + 'api/listar_emisoras.json?callback=JSON_CALLBACK';
		$http.jsonp(url)
			.success(function(data){
			  $rootScope.emisoras = data.data;
			  emisora_seleccionada = $rootScope.emisoras[$stateParams.emisoraId-1];
			  //document.getElementById('cargando_listado').style.display = 'none';
			}).error(function(error) {
				// Ir a pantalla de error de conexion.
				$location.url("/app/error");
			});
			
	   // emisora_seleccionada = $rootScope.emisoras[$stateParams.emisoraId-1];
    }

    // Verifico variables para el footer
	if ($rootScope.audio && $rootScope.nombre){
		$scope.footer_display_text = 'none';
		$scope.footer_display_button = 'block';
		$scope.nombre = $rootScope.nombre;
	} else {
		$scope.footer_display_text = 'block';
		$scope.footer_display_button = 'none';
	}

	// Si tiene frecuencia fm armar url para streaming y a pedido de excepción setear texto Onda Corta.
    if (emisora_seleccionada.fm != "") {
		$scope.url_streaming_fm = 'http://' + emisora_seleccionada.urlstreaming1 + ':' + emisora_seleccionada.puerto + emisora_seleccionada.fm;
		$scope.url_streaming_label_fm = 'FM';
		mostrar = 'fm';
    } else {
		$scope.url_streaming_fm = false;
	}

	// Si tiene frecuencia am armar url para streaming y a pedido de excepción setear texto Onda Corta.
	if (emisora_seleccionada.am != '') {
		$scope.url_streaming_am = 'http://' + emisora_seleccionada.urlstreaming1 + ':' + emisora_seleccionada.puerto + emisora_seleccionada.am;
		if (emisora_seleccionada.first_name == 'RAE' || emisora_seleccionada.first_name == 'LRA 36') {
			$scope.url_streaming_label_am = 'Onda corta';
		} else {
			$scope.url_streaming_label_am = 'AM';
		}
		mostrar = 'am';
	} else {
		$scope.url_streaming_am = false;
	}

	// Si por parámetro recibo cuál quiere el usuario setearlo.
	if ($stateParams.frecuencia == 'am' || $stateParams.frecuencia == 'fm') {
		var mostrar = false;
		if ($stateParams.frecuencia == 'fm') {
			mostrar = 'fm';
		} else if ($stateParams.frecuencia == 'am') {
			mostrar = 'am';
		}
	}

	$scope.url_fb = emisora_seleccionada.urlfb;
	$scope.url_tw = emisora_seleccionada.urltw;
	if (emisora_seleccionada.web != "") {
		$scope.url_web = emisora_seleccionada.web;
	} else {
	    $scope.url_web = false;
	}
    $scope.id = emisora_seleccionada.id;
	$scope.onda = 'FM';

	if (emisora_seleccionada.first_name != 'RAE') {
	    //$scope.nombre_emisora = 'Nacional ' + emisora_seleccionada.last_name;
		$scope.nombre_emisora = emisora_seleccionada.last_name;
	} else {
	    $scope.nombre_emisora = emisora_seleccionada.last_name;
	}

	$scope.dialAm = emisora_seleccionada.dialAM;
	$scope.dialFm = emisora_seleccionada.dialFM;

	if (emisora_seleccionada.am != '' && mostrar == 'am') {
		$scope.bandera_am = 'inline';
		$scope.bandera_fm = 'none';
		$scope.bandera_ex = 'none';
        url = ws + 'api/listar_programacion_actual/' + emisora_seleccionada.id + '/AM/.json?callback=JSON_CALLBACK';
	} else if (emisora_seleccionada.fm != '' && mostrar == 'fm') {
		$scope.bandera_fm = 'inline';
		$scope.bandera_am = 'none';
		$scope.bandera_ex = 'none';
        url = ws + 'api/listar_programacion_actual/' + emisora_seleccionada.id + '/FM/.json?callback=JSON_CALLBACK';
	} else {
		// Se utilizó para poner las de próximamente.
		// if (emisora_seleccionada.first_name == 'LRA 43') {
			// $scope.bandera_ex = 'inline';
		// }
		// $scope.bandera_fm = 'none';
		// $scope.bandera_am = 'none';
	}

 	$http.jsonp(url)
		.success(function(data_programa){
		    // Si tengo data puedo setear las variables para el template.
			if (data_programa.data['nombre']) {
				$scope.titulo_programa = data_programa.data['nombre'];
			} else {
				$scope.titulo_programa = '';
			}

			if (data_programa.data['descripcion']) {
				$scope.descripcion_programa = data_programa.data['descripcion'];
			} else {
				$scope.descripcion_programa = '';
			}
			//console.log(data_programa);
			if (data_programa.data['imagen']) {
				$scope.altominimo = Math.round(screen.width - (screen.width*56/100))+'px';
				$scope.imagen_programa = ws + 'files/' + data_programa.data['imagen'];
			} else {
				// poner imagen default
				//$scope.imagen_programa = 'img/default.png';
                $scope.imagen_programa = '';
			}

			if (emisora_seleccionada.image) {
				$scope.imagen_emisora = ws + 'files/' + emisora_seleccionada.image;
			} else {
				// poner imagen default
				$scope.imagen_emisora = '';
			}

        }).error(function(error) {
            // Ir a pantalla de error de conexion.
            $location.url("/app/error");
        });


	// Realizar notificación.
	$scope.addM = function(titulo, mensaje) {
			// var alarmTime = new Date();
			// alarmTime.setMinutes(alarmTime.getMinutes() + 1);
			$cordovaLocalNotification.add({
				id: "1",
				message: titulo,
				title: mensaje,
				autoCancel: false,
				ongoing: false
			}).then(function () {
				//console.log("The notification has been set");
			});

	}

	// Función para realizar el play
    $scope.play = function(src, tipo) {
		if ($rootScope.audio){
		    $rootScope.audio.pause();
		    $rootScope.audio = null;
		    document.getElementById('texto').style.display = 'block';
		    document.getElementById('botonParar').style.display = 'none';
		}

    	if (tipo == 'AM') {
			$scope.pButton = document.getElementById('rep');
			$scope.sButton = document.getElementById('para');
			$scope.aButton = document.getElementById('cargando');
			document.getElementById('rep1').style.display = 'block';
			document.getElementById('para1').style.display = 'none';
			document.getElementById('cargando1').style.display = 'none';
        } else {
			$scope.pButton = document.getElementById('rep1');
			$scope.sButton = document.getElementById('para1');
			$scope.aButton = document.getElementById('cargando1');
			document.getElementById('rep').style.display = 'block';
			document.getElementById('para').style.display = 'none';
			document.getElementById('cargando').style.display = 'none';
		}

        $scope.pButton.style.display = 'block';
		$scope.sButton.style.display = 'none';
		$scope.aButton.style.display = 'none';
		$rootScope.audio = new Audio(src);
		isPlaying = true;
		$rootScope.audio.play({ playAudioWhenScreenIsLocked : true });
		
		readyStateInterval = setInterval(function(){
			if ($rootScope.audio != null) {
			 if ($rootScope.audio.readyState <= 2) {
				$scope.pButton.style.display = 'none';
				$scope.sButton.style.display = 'none';
				$scope.aButton.style.display = 'block';
			 }
			}
		},1000);
		$rootScope.audio.addEventListener("error", function() {
			//console.log('myaudio ERROR');
			isPlaying = false;
			$scope.pButton.style.display = 'block';
			$scope.sButton.style.display = 'none';
			$scope.aButton.style.display = 'none';
			$rootScope.nombre = '';
			$rootScope.audio = null;	
			alert("Emisora no disponible en este momento.");
		}, false);
		$rootScope.audio.addEventListener("canplay", function() {
			// console.log('myaudio CAN PLAY');
			$scope.pButton.style.display = 'none';
			$scope.sButton.style.display = 'block';
			$scope.aButton.style.display = 'none';
			$rootScope.nombre = $scope.nombre_emisora;			
		}, false);
		$rootScope.audio.addEventListener("waiting", function() {
			// console.log('myaudio WAITING');
			 isPlaying = false;
			$scope.pButton.style.display = 'none';
			$scope.sButton.style.display = 'none';
			$scope.aButton.style.display = 'block';
		}, false);
		$rootScope.audio.addEventListener("playing", function() {
			 isPlaying = true;
			// $scope.pButton.style.display = 'none';
			// $scope.sButton.style.display = 'block';
			// $scope.aButton.style.display = 'none';
		}, false);
		$rootScope.audio.addEventListener("ended", function() {
			// console.log('myaudio ENDED');
			 // html5audio.stop();
			isPlaying = false;
			$scope.pButton.style.display = 'block';
			$scope.sButton.style.display = 'none';
			$scope.aButton.style.display = 'none';				 
			 // navigator.notification.alert('Streaming failed. Possibly due to a network error.', null, 'Stream error', 'OK');
			 // navigator.notification.confirm(
			 //	'Streaming failed. Possibly due to a network error.', // message
			 //	onConfirmRetry,	// callback to invoke with index of button pressed
			 //	'Stream error',	// title
			 //	'Retry,OK'		// buttonLabels
			 // );
			 // if (window.confirm('Streaming failed. Possibly due to a network error. Retry?')) {
			 	// onConfirmRetry();
			 // }
		}, false);		

    }

	// Función para realizar stop
    $scope.stop = function() {
		$rootScope.audio.pause();
		$rootScope.audio = '';
		$scope.footer_display_text = 'block';
		$scope.footer_display_button = 'none';
		document.getElementById('texto').style.display = 'block';
		document.getElementById('botonParar').style.display = 'none';
		if ($scope.pButton	) {
			$scope.pButton.style.display = 'block';
			$scope.sButton.style.display = 'none';
			$scope.aButton.style.display = 'none';
		}
		$rootScope.nombre = '';
		clearInterval(readyStateInterval);
	}

    function onError (error) {
		alert("Error al obtener datos del servidor.");
    }

    var mediaStatusCallback = function(status) {
		 /*
		  * 1 cargando
		  * 1 cargando
		  * 2 can play
		  * 4 stop
		  */
        if(status == 1) {
            $scope.pButton.style.display = 'none';
		    $scope.sButton.style.display = 'none';
		    $scope.aButton.style.display = 'block';
        } else if (status == 2) {
            $scope.pButton.style.display = 'none';
			$scope.sButton.style.display = 'block';
			$scope.aButton.style.display = 'none';
		    $rootScope.nombre = $scope.nombre_emisora;
        } else if (status == 4){
            $scope.pButton.style.display = 'block';
			$scope.sButton.style.display = 'none';
			$scope.aButton.style.display = 'none';
		}
    }

	// Abrir urls.
	$scope.open = function(url) {
		window.open(url, '_blank', 'location=yes');
	}

   $scope.am = function() {
   // Esto lo meto en el scope
	var div = document.getElementById("repAm");
	var div2 = document.getElementById("repFm");
	var div3 = document.getElementById("noticias");
	div.style.display = 'block';
	div2.style.display = 'none';
    div3.style.display = 'none';
	$scope.onda = 'AM';
   }

  $scope.fm = function() {
   // Esto lo meto en el scope
	var div = document.getElementById("repAm");
	var div2 = document.getElementById("repFm");
	var div3 = document.getElementById("noticias");
    div3.style.display = 'none';
	div2.style.display = 'block';
	div.style.display = 'none';
	$scope.onda = 'FM';
  }

  $scope.mostrar_noticias = function() {
	var div3 = document.getElementById("lista");
	var div4 = document.getElementById("cargando_noticias");

	var url_noticias = $scope.url_web + '&callback=JSON_CALLBACK';
	$http.jsonp(url_noticias)
		.success(function(data){
			document.getElementById("cargando_noticias").style.display = 'none';
			$scope.noticias = data.posts;
    	    div3.style.display = 'block';
			for (var i=0; i < $scope.noticias.length; i++) {
				// Reemplazo caracteres raros y seteo ícono por defautl si no trae nada.
     			var v =  $scope.noticias[i].title.replace( /<[^>]+>/g, '' );
				var v =  v.replace( '&#8220;', '"');
				var v =  v.replace( '&#8221;', '"');
				var v =  v.replace( '&#8230;', '...');
    			var v =  v.replace( '&#8211;', '-');
				var v =  v.replace( '&#8217;', "'");
				$scope.noticias[i].title = v;
				if (typeof $scope.noticias[i].thumbnail_images == 'undefined') {
					$scope.noticias[i].comments = '/img/icono.png';
				} else if (typeof $scope.noticias[i].thumbnail_images.medium == 'undefined') {
					if (typeof $scope.noticias[i].thumbnail_images.full == 'undefined') {
						$scope.noticias[i].comments = '/img/icono.png';
					} else {
						$scope.noticias[i].comments = $scope.noticias[i].thumbnail_images.full.url;
					}
				} else {
					$scope.noticias[i].comments = $scope.noticias[i].thumbnail_images.medium.url;
				}
				
				//console.log($scope.noticias[i].comments);
			if (typeof $scope.noticias[i].custom_fields.volanta_1 != 'undefined') {
					var v = $scope.noticias[i].custom_fields.volanta_1.toString();
					var v = v.replace('["', '');
					$scope.noticias[i].custom_fields.volanta_1 = v;
				}
			}
		}).error(function(error) {
            // Ir a pantalla de error de conexion.
            $location.url("/app/error");
        });
  }

  $scope.programacion_completa = function(id, dial) {
      $location.url("/app/programacion/" + id + "/" + dial);

  }

  $scope.programacion = function() {
	var div3 = document.getElementById("lista");
	var div4 = document.getElementById("cargando_noticias");
    $scope.error_programacion = false;

    if (!emisora_seleccionada) {
        $location.url("/app/emisoras/no");
        return;
    }

    var url = ws + "api/listar_programacion_diaria_banda/" + emisora_seleccionada.id + "/" + $stateParams.banda + "/.json?callback=JSON_CALLBACK";
	//console.log(url);
	$http.jsonp(url)
    	.success(function(datos){
			//console.log("datos:" + datos);
  		    $scope.prog = datos.data;
			if ($scope.prog.nombre == 'Programación no disponible') {
			   $scope.error_programacion = true;
			}
			document.getElementById('cargando_noticias').style.display = 'none';
        }).error(function(error) {
            // Ir a pantalla de error de conexion.
			// console.log("Error");
            $location.url("/app/error");
        });
  }

    /* Insert para favoritos */
    $scope.save = function(parametro_emisora) {

        $cordovaSQLite.execute(db, 'INSERT INTO favoritos (emisora) VALUES (?)', [parametro_emisora])
            .then(function(result) {
				var confirmPopup = $ionicPopup.confirm({
				title: 'Lista de Favoritos.',
				template: 'Se agregó la emisora a la lista de favoritos.',
				cancelText: 'Cancelar',
				//okText: 'Salir'
				});
				// confirmPopup.then(function(res) {
					// if(res) {
						// navigator.app.exitApp();
					// }
			   // });	
				
				//alert("se guardo");
                //$scope.statusMessage = "Message saved successful, cheers!";
            }, function(error) {
                //$scope.statusMessage = "Error on saving: " + error.message;
				//alert("error al guardar");
            })

    }

});

angular.element(document).ready(function() {
	angular.bootstrap(document, ['starter']);
});