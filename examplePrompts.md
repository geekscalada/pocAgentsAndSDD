
# API-front dummy

Desarrolla una API rest dummy en express que va a ser consultada por un servicio Angular. 
La API constará de un solo GET con base URL `http://localhost:3000/temperature`.
El path es la ciudad y la feccha es el día que queremos consultar, insertado por timestamp de 13 dígitos en el queryParam.
La API devolverá un JSON con la temperatura máxima y mínima de ese día en esa ciudad, con datos dummy hardcodeados.
El front constará de un placeholder donde añadir la ciudad y un botón rojo "buscar".
Al hacer click en el botón, se hará la consulta a la API y se mostrarán los resultados debajo del botón, en letras grandes y azules.