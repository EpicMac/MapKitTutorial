# Mapkit Tutorial
> En este tutorial aprenderas a utilizar Mapkit, el cual te permite permitir desplegar tu ubicación, anotaciones y cómo obtener direcciones para llegar a un punto específico.


## Tabla de contenidos
* [Ubicación](#ubicación)
* [Anotaciones](#anotaciones)
* [Direcciones](#direcciones) 
* [Video](#video)

## Ubicación
Para poder trabajar con todas las herramientas de MapKit debes insertar el siguiente codigo
`import Mapkit`

Despues deberemos crear una variable de tipo CLLocationManager de la siguiente manera

`private let locationManager= CLLocationManager()`

CLLocationManager es el objeto que utiliza para iniciar y detener la entrega de eventos relacionados con la ubicación a su aplicación.

Despues se necesita obtener los permisos del usario para asi poder detectar su ubicación, esto se hara atraves del siguiente codigo

```
 private func configureLocationServices(){
        locationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse{
            
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        	locationManager.startUpdatingLocation()
        }
    }

```

Ademas se deberan agregar algunas funciones para que el locationManager pueda seguir funcionando

```

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
}

```

Para que Apple no nos marque error debemos ir a info.plist y agregar el porque se requiere la ubicación

Ademas se necesita guardar la ubicación actual
` private var currentCoordinate: CLLocationCoordinate2D?`

Agregar el siguiente codigo a funcion didUpdateLocations
`   guard let latestLocation = locations.first else { return }`
`   currentLocation = latestLocation.coordinate`


En la función de configureLocationServices en la parte else if status == .authorizedAlways || status == .authorizedWhenInUse, agregar:
`MapView.showsUserLocation = true`

Ya con todo esto se deberia poder mostrar la ubicacion actual, pero se usara una función de zoom a la locacion actual

```
 private func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        MapView.setRegion(region, animated: true)
    }
```

esa funcion se debe mandar a llamar en la funcion didUpdateLocations de la siguiente forma:
```
 guard let latestLocation = locations.first else { return }

if currentCoordinate == nil {
            zoomToLatestLocation(with: latestLocation.coordinate)
            
        }
        
        currentCoordinate = latestLocation.coordinate

```

Ya para acabar esta sección modificaremos algo del codigo ya escrito
```
  private func beginLocationUpdates(locationManager: CLLocationManager){
        MapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
```

remplazar la parte del configureLocationServices por esta funcion y modicar la funcion didChangeAuthorization de la siguiente manera:
```
func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("The status changed")
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: manager)
        }
    }

```
### Correr la app

	
## Anotaciones

Agregar la siguiente función

```
private func addAnnotations(){
        let MuseoAntro = MKPointAnnotation()
        MuseoAntro.title="Museo de Antropologia"
        MuseoAntro.subtitle="Museo de antropologia e historia"
        MuseoAntro.coordinate=CLLocationCoordinate2D(latitude: 19.2737619, longitude: -99.702382)
        
        MapView.addAnnotation(MuseoAntro)
    }

```

El titulo, subtitulo y coordenadas pueden ser cambiadas

por ultimo mandar a llamar esta función en didUpdateLocations

### Correr la app

## Direcciones

Definir las siguientes variables: 

`private var destinations: [MKAnnotation]=[]`
`private var currentRoute: MKRoute?`

agregar a la función de addAnotations()
`destinations.append(MuseoAntro)`

Ahora se creará la ruta

```
private func constructRoute(userLocation: CLLocationCoordinate2D){
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        directionsRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinations[0].coordinate))
        directionsRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionsRequest)
        
        directions.calculate { [weak self] (directionsResponse, error) in
            
            guard let strongSelf = self else { return }
            
            if let error = error {
                print(error.localizedDescription)
            } else if let response = directionsResponse, response.routes.count > 0 {
                
                strongSelf.currentRoute = response.routes[0]
                strongSelf.MapView.addOverlay(response.routes[0].polyline)
                strongSelf.MapView.setVisibleMapRect(response.routes[0].polyline.boundingMapRect, animated: true)
            }
        }
        
    }

```

Mandar a llamar en didUpdateLocations

` constructRoute(userLocation: latestLocation.coordinate)`

Crear una extension de tipo MapViewDelegate

```
extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        guard let currentRoute = currentRoute else{
            return MKOverlayRenderer()
        }
        
        let polyLineRenderer = MKPolylineRenderer(polyline: currentRoute.polyline)
        polyLineRenderer.strokeColor = UIColor.blue
        
        
        return polyLineRenderer
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("The annotation was selected: \(String(describing: view.annotation?.title))")
    }
}

```

### Correr la app


## Video

Para un mayor entendimiento ver el siguiente video:
### https://www.youtube.com/watch?v=1hGGDh5U4eM&feature=youtu.be
