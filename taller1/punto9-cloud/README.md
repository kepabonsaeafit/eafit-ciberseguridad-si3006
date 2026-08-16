# Punto 9 — Arquitectura Cloud
### a.	Que servicios, protocolos o sistemas de seguridad perimetral se deben de añadir a la arquitectura para mejorar su seguridad
Para mejorar la seguridad de la arquitectura se deben de añadir estos servicios, protocolos y sistemas de seguridad perimetral:

**HTTPS/TLS:** cifra la comunicacion entre el usuario y la aplicacion asi evitando que la informacion sea interceptada

**AWS WAF:** analiza las solicitudes y bloquea ataques, manipulacion de la base de datos, codigo malicioso, bots e intentos repetidos de acceso 

**AWS Shield:** protege la infraestructura de ataques que buscan saturar la aplicacion a traves de una gran cantidad de solicitudes al mismo tiempo haciendo que la aplicacion se vuelva lenta o deje de funcionar

**Application load balancer:** se usa como unico punto de entrada, recibe las conexiones HTTPS y las distribuye hacia la aplicacion evitando que los usuarios se conecten directamente con los microservicios 

**Amazon VPC:** crea una red privada para aislar y proteger los microservicios y las bases de datos del acceso directo desde internet 

**Security groups:** controla que servicios pueden comunicarse entre si y por que puertos 

**Network ACL:** controla el trafico de entrada y salida de cada subred y proporciona una segunda capa de proteccion

**API gateway:** controla el accesoo a los microservicios, valida solicitudes, limita la cantidad de peticiones y evita que las API internas queden expuestas directamente 
Estos servicios, protocolos y sistemas de seguridad perimetral crean diferentes capaz de proteccion para que el usuario solo pueda accedes al punto de entrada autorizado, mientras que los microservicios y las bases de datos mantengan aislados y protegidos. 
