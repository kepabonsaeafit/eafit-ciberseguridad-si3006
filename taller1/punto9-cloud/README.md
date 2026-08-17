# Punto 10 — Arquitectura Cloud
<img width="250" height="262" alt="image" src="https://github.com/user-attachments/assets/f51afc68-1650-4104-bcc7-4f646382b47d" />

### Descripción de la arquitectura actual 
La arquitectura actual se encuentra en AWS y tiene un Front-End desde el cual los usuarios ingresan a la aplicación. El Front-End se comunica directamente con tres microservicios encargados de administrar los usuarios, los permisos y el monitoreo. También cuenta con dos funciones Lambda: una para guardar los registros y otra para realizar validaciones con Jira. Finalmente, tiene una base de datos llamada UsersDB, donde se guarda la información de los usuarios, y otra llamada LogsDB, donde se almacenan los registros de las actividades realizadas.


### Debilidades identificadas 
La arquitectura actual no muestra suficientes medidas de seguridad. No se especifica el uso de HTTPS para proteger la información, no tiene WAF para bloquear solicitudes maliciosas ni Shield para proteger la aplicación de ataques DDoS. El Front-End aparece como punto de entrada directo y se comunica con los microservicios sin utilizar un API Gateway.

Tampoco existe una separación clara entre los servicios públicos, los microservicios y las bases de datos. No se muestran subredes públicas y privadas, Security Groups ni Network ACL. Además, no se explica cómo se protegen las credenciales de las bases de datos y de Jira, cómo se administran los permisos, si las bases de datos están cifradas o si existen copias de seguridad. Finalmente, no se muestran servicios para monitorear la actividad y detectar posibles amenazas.

### Servicios, protocolos y sistemas de seguridad propuestos 
Para mejorar la seguridad de la arquitectura se propone agregar diferentes medidas organizadas en seis capas.

1. La protección de la entrada. Se utilizará HTTPS/TLS para cifrar la comunicación entre el usuario y la aplicación, evitando que la información sea interceptada. También se agregará AWS WAF para analizar las solicitudes y bloquear ataques como inyección SQL, código malicioso, bots e intentos repetidos de acceso. Además, AWS Shield protegerá la infraestructura contra ataques DDoS, los cuales buscan saturar la aplicación enviando una gran cantidad de solicitudes al mismo tiempo.

2. El control de las solicitudes. Se agregará un Application Load Balancer como único punto de entrada. Este recibirá las conexiones HTTPS y las enviará hacia el Front-End, evitando que los usuarios se conecten directamente con los servicios internos. También se propone API Gateway entre el Front-End y los microservicios para validar las solicitudes, limitar la cantidad de peticiones y evitar que las API internas queden expuestas directamente.

3. La seguridad de la red. Se utilizará una Amazon VPC para crear una red privada y separar los componentes de la aplicación. Dentro de la VPC habrá una subred pública para el Load Balancer y el NAT Gateway, una subred privada para el Front-End, los microservicios y las funciones Lambda, y subredes privadas para UsersDB y LogsDB. Los Security Groups controlarán qué servicios pueden comunicarse entre sí y por cuáles puertos. Las Network ACL controlarán el tráfico de entrada y salida de cada subred y proporcionarán una segunda capa de protección. El NAT Gateway permitirá que Lambda Jira Validator se comunique con Jira sin quedar expuesta directamente a Internet.

4. La gestión de identidades y credenciales. AWS IAM permitirá asignar roles y permisos mínimos a cada servicio. Por ejemplo, Lambda Logs solamente tendrá permisos para guardar información en LogsDB. AWS Secrets Manager almacenará de forma segura las contraseñas de las bases de datos, el token de Jira y otras credenciales, evitando que queden guardadas directamente en el código.

5. La protección de los datos. AWS KMS permitirá cifrar la información guardada en UsersDB y LogsDB. AWS Backup realizará copias de seguridad automáticas para poder recuperar la información en caso de pérdida, daño, eliminación accidental o ataque. Las bases de datos estarán dentro de subredes privadas y no tendrán acceso directo desde Internet.

6. El monitoreo. Amazon CloudWatch recopilará registros y métricas de la aplicación y permitirá generar alertas. AWS CloudTrail registrará las acciones realizadas dentro de AWS, como cambios en permisos o configuraciones. Amazon GuardDuty analizará la actividad para detectar accesos sospechosos, credenciales comprometidas y posibles ataques.

### Nuevo modelo de arquitectura basado en el mostrado con las medidas de seguridad planteadas por el grupo
<img width="976" height="1068" alt="image" src="https://github.com/user-attachments/assets/5703527e-bf16-453a-8000-d32da4e48c1d" />

### Explicación de la nueva arquitectura 

En la nueva arquitectura, el usuario se conecta mediante HTTPS. AWS WAF analiza las solicitudes y AWS Shield protege la aplicación contra ataques DDoS. El Application Load Balancer recibe las conexiones y las envía al Front-End. El Front-End se comunica con los microservicios, los cuales están protegidos dentro de una subred privada.

UsersDB y LogsDB se encuentran en subredes privadas diferentes y solo aceptan conexiones de los servicios autorizados. IAM controla los permisos, Secrets Manager protege las credenciales, KMS cifra las bases de datos y AWS Backup realiza copias de seguridad. CloudWatch, CloudTrail y GuardDuty permiten monitorear la infraestructura y detectar actividades sospechosas.

### Conclusion 

Con estas medidas se crean diferentes capas de seguridad. El usuario solamente puede acceder por el punto de entrada autorizado, mientras que los microservicios y las bases de datos permanecen aislados dentro de la VPC. También se protegen las comunicaciones, las credenciales y la información almacenada, y se agregan herramientas para monitorear y detectar posibles amenazas.
