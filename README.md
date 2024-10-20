#Dólar Cotización App

Este proyecto desarrollado en Flutter sirve para consultar y visualizar la cotización del dólar. La aplicación obtiene los datos de la API dolarapi.com y permite ver las variaciones del dólar a lo largo del tiempo.

##Características

- Consulta el endpoint de la API para obtener cotizaciones del dólar en tiempo real.
- Almacena localmente el valor del dólar "Oficial" y otros tipos (Blue, Cripto, Mayorista, etc.) para comparar variaciones.
- Permite buscar y visualizar la cotización del dólar para una fecha específica mediante un calendario.

##Instalación

git clone  
cd cotizacionDolar
flutter pub get
flutter run


##Dependencias

hive_flutter: Para almacenamiento local.
intl: Para formateo de fechas.
http: Para hacer solicitudes HTTP a la API.
